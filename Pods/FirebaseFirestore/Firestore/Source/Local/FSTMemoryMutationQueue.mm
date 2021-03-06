/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Firestore/Source/Local/FSTMemoryMutationQueue.h"

#import <Protobuf/GPBProtocolBuffers.h>

#include <set>

#import "Firestore/Protos/objc/firestore/local/Mutation.pbobjc.h"
#import "Firestore/Source/Core/FSTQuery.h"
#import "Firestore/Source/Local/FSTMemoryPersistence.h"
#import "Firestore/Source/Model/FSTMutation.h"
#import "Firestore/Source/Model/FSTMutationBatch.h"

#include "Firestore/core/src/firebase/firestore/immutable/sorted_set.h"
#include "Firestore/core/src/firebase/firestore/local/document_reference.h"
#include "Firestore/core/src/firebase/firestore/model/document_key.h"
#include "Firestore/core/src/firebase/firestore/model/resource_path.h"
#include "Firestore/core/src/firebase/firestore/util/hard_assert.h"

using firebase::firestore::immutable::SortedSet;
using firebase::firestore::local::DocumentReference;
using firebase::firestore::model::BatchId;
using firebase::firestore::model::DocumentKey;
using firebase::firestore::model::DocumentKeySet;
using firebase::firestore::model::ResourcePath;

NS_ASSUME_NONNULL_BEGIN

static const NSComparator NumberComparator = ^NSComparisonResult(NSNumber *left, NSNumber *right) {
  return [left compare:right];
};

@interface FSTMemoryMutationQueue ()

/**
 * A FIFO queue of all mutations to apply to the backend. Mutations are added to the end of the
 * queue as they're written, and removed from the front of the queue as the mutations become
 * visible or are rejected.
 *
 * When successfully applied, mutations must be acknowledged by the write stream and made visible
 * on the watch stream. It's possible for the watch stream to fall behind in which case the batches
 * at the head of the queue will be acknowledged but held until the watch stream sees the changes.
 *
 * If a batch is rejected while there are held write acknowledgements at the head of the queue
 * the rejected batch is converted to a tombstone: its mutations are removed but the batch remains
 * in the queue. This maintains a simple consecutive ordering of batches in the queue.
 *
 * Once the held write acknowledgements become visible they are removed from the head of the queue
 * along with any tombstones that follow.
 */
@property(nonatomic, strong, readonly) NSMutableArray<FSTMutationBatch *> *queue;

/** The next value to use when assigning sequential IDs to each mutation batch. */
@property(nonatomic, assign) BatchId nextBatchID;

/**
 * The last received stream token from the server, used to acknowledge which responses the client
 * has processed. Stream tokens are opaque checkpoint markers whose only real value is their
 * inclusion in the next request.
 */
@property(nonatomic, strong, nullable) NSData *lastStreamToken;

@end

using DocumentReferenceSet = SortedSet<DocumentReference, DocumentReference::ByKey>;

@implementation FSTMemoryMutationQueue {
  FSTMemoryPersistence *_persistence;
  /** An ordered mapping between documents and the mutation batch IDs. */
  DocumentReferenceSet _batchesByDocumentKey;
}

- (instancetype)initWithPersistence:(FSTMemoryPersistence *)persistence {
  if (self = [super init]) {
    _persistence = persistence;
    _queue = [NSMutableArray array];

    _nextBatchID = 1;
  }
  return self;
}

#pragma mark - FSTMutationQueue implementation

- (void)start {
  // Note: The queue may be shutdown / started multiple times, since we maintain the queue for the
  // duration of the app session in case a user logs out / back in. To behave like the
  // LevelDB-backed MutationQueue (and accommodate tests that expect as much), we reset nextBatchID
  // if the queue is empty.
  if (self.isEmpty) {
    self.nextBatchID = 1;
  }
}

- (BOOL)isEmpty {
  // If the queue has any entries at all, the first entry must not be a tombstone (otherwise it
  // would have been removed already).
  return self.queue.count == 0;
}

- (void)acknowledgeBatch:(FSTMutationBatch *)batch streamToken:(nullable NSData *)streamToken {
  NSMutableArray<FSTMutationBatch *> *queue = self.queue;

  BatchId batchID = batch.batchID;

  NSInteger batchIndex = [self indexOfExistingBatchID:batchID action:@"acknowledged"];
  HARD_ASSERT(batchIndex == 0, "Can only acknowledge the first batch in the mutation queue");

  // Verify that the batch in the queue is the one to be acknowledged.
  FSTMutationBatch *check = queue[(NSUInteger)batchIndex];
  HARD_ASSERT(batchID == check.batchID, "Queue ordering failure: expected batch %s, got batch %s",
              batchID, check.batchID);

  self.lastStreamToken = streamToken;
}

- (FSTMutationBatch *)addMutationBatchWithWriteTime:(FIRTimestamp *)localWriteTime
                                          mutations:(NSArray<FSTMutation *> *)mutations {
  HARD_ASSERT(mutations.count > 0, "Mutation batches should not be empty");

  BatchId batchID = self.nextBatchID;
  self.nextBatchID += 1;

  NSMutableArray<FSTMutationBatch *> *queue = self.queue;
  if (queue.count > 0) {
    FSTMutationBatch *prior = queue[queue.count - 1];
    HARD_ASSERT(prior.batchID < batchID,
                "Mutation batchIDs must be monotonically increasing order");
  }

  FSTMutationBatch *batch = [[FSTMutationBatch alloc] initWithBatchID:batchID
                                                       localWriteTime:localWriteTime
                                                            mutations:mutations];
  [queue addObject:batch];

  // Track references by document key.
  for (FSTMutation *mutation in batch.mutations) {
    _batchesByDocumentKey = _batchesByDocumentKey.insert(DocumentReference{mutation.key, batchID});
  }

  return batch;
}

- (nullable FSTMutationBatch *)lookupMutationBatch:(BatchId)batchID {
  NSMutableArray<FSTMutationBatch *> *queue = self.queue;

  NSInteger index = [self indexOfBatchID:batchID];
  if (index < 0 || index >= queue.count) {
    return nil;
  }

  FSTMutationBatch *batch = queue[(NSUInteger)index];
  HARD_ASSERT(batch.batchID == batchID, "If found batch must match");
  return batch;
}

- (nullable FSTMutationBatch *)nextMutationBatchAfterBatchID:(BatchId)batchID {
  NSMutableArray<FSTMutationBatch *> *queue = self.queue;

  BatchId nextBatchID = batchID + 1;

  // The requested batchID may still be out of range so normalize it to the start of the queue.
  NSInteger rawIndex = [self indexOfBatchID:nextBatchID];
  NSUInteger index = rawIndex < 0 ? 0 : (NSUInteger)rawIndex;
  return queue.count > index ? queue[index] : nil;
}

- (NSArray<FSTMutationBatch *> *)allMutationBatches {
  return [[self queue] copy];
}

- (NSArray<FSTMutationBatch *> *)allMutationBatchesAffectingDocumentKey:
    (const DocumentKey &)documentKey {
  NSMutableArray<FSTMutationBatch *> *result = [NSMutableArray array];

  DocumentReference start{documentKey, 0};
  for (const auto &reference : _batchesByDocumentKey.values_from(start)) {
    if (documentKey != reference.key()) break;

    FSTMutationBatch *batch = [self lookupMutationBatch:reference.ref_id()];
    HARD_ASSERT(batch, "Batches in the index must exist in the main table");
    [result addObject:batch];
  }

  return result;
}

- (NSArray<FSTMutationBatch *> *)allMutationBatchesAffectingDocumentKeys:
    (const DocumentKeySet &)documentKeys {
  // First find the set of affected batch IDs.
  std::set<BatchId> batchIDs;
  for (const DocumentKey &key : documentKeys) {
    DocumentReference start{key, 0};

    for (const auto &reference : _batchesByDocumentKey.values_from(start)) {
      if (key != reference.key()) break;

      batchIDs.insert(reference.ref_id());
    }
  }

  return [self allMutationBatchesWithBatchIDs:batchIDs];
}

- (NSArray<FSTMutationBatch *> *)allMutationBatchesAffectingQuery:(FSTQuery *)query {
  // Use the query path as a prefix for testing if a document matches the query.
  const ResourcePath &prefix = query.path;
  size_t immediateChildrenPathLength = prefix.size() + 1;

  // Construct a document reference for actually scanning the index. Unlike the prefix, the document
  // key in this reference must have an even number of segments. The empty segment can be used as
  // a suffix of the query path because it precedes all other segments in an ordered traversal.
  ResourcePath startPath = query.path;
  if (!DocumentKey::IsDocumentKey(startPath)) {
    startPath = startPath.Append("");
  }
  DocumentReference start{DocumentKey{startPath}, 0};

  // Find unique batchIDs referenced by all documents potentially matching the query.
  std::set<BatchId> uniqueBatchIDs;
  for (const auto &reference : _batchesByDocumentKey.values_from(start)) {
    const ResourcePath &rowKeyPath = reference.key().path();
    if (!prefix.IsPrefixOf(rowKeyPath)) {
      break;
    }

    // Rows with document keys more than one segment longer than the query path can't be matches.
    // For example, a query on 'rooms' can't match the document /rooms/abc/messages/xyx.
    // TODO(mcg): we'll need a different scanner when we implement ancestor queries.
    if (rowKeyPath.size() != immediateChildrenPathLength) {
      continue;
    }

    uniqueBatchIDs.insert(reference.ref_id());
  };

  return [self allMutationBatchesWithBatchIDs:uniqueBatchIDs];
}

/**
 * Constructs an array of matching batches, sorted by batchID to ensure that multiple mutations
 * affecting the same document key are applied in order.
 */
- (NSArray<FSTMutationBatch *> *)allMutationBatchesWithBatchIDs:
    (const std::set<BatchId> &)batchIDs {
  NSMutableArray<FSTMutationBatch *> *result = [NSMutableArray array];
  for (BatchId batchID : batchIDs) {
    FSTMutationBatch *batch = [self lookupMutationBatch:batchID];
    if (batch) {
      [result addObject:batch];
    }
  };

  return result;
}

- (void)removeMutationBatch:(FSTMutationBatch *)batch {
  NSMutableArray<FSTMutationBatch *> *queue = self.queue;
  BatchId batchID = batch.batchID;

  // Find the position of the first batch for removal. This need not be the first entry in the
  // queue.
  NSUInteger batchIndex = [self indexOfExistingBatchID:batchID action:@"removed"];
  HARD_ASSERT(batchIndex == 0, "Can only remove the first entry of the mutation queue");

  [queue removeObjectAtIndex:0];

  // Remove entries from the index too.
  for (FSTMutation *mutation in batch.mutations) {
    const DocumentKey &key = mutation.key;
    [_persistence.referenceDelegate removeMutationReference:key];

    DocumentReference reference{key, batchID};
    _batchesByDocumentKey = _batchesByDocumentKey.erase(reference);
  }
}

- (void)performConsistencyCheck {
  if (self.queue.count == 0) {
    HARD_ASSERT(_batchesByDocumentKey.empty(),
                "Document leak -- detected dangling mutation references when queue is empty.");
  }
}

#pragma mark - FSTGarbageSource implementation

- (BOOL)containsKey:(const DocumentKey &)key {
  // Create a reference with a zero ID as the start position to find any document reference with
  // this key.
  DocumentReference reference{key, 0};

  auto range = _batchesByDocumentKey.values_from(reference);
  auto begin = range.begin();
  return begin != range.end() && begin->key() == key;
}

#pragma mark - Helpers

/**
 * Finds the index of the given batchID in the mutation queue. This operation is O(1).
 *
 * @return The computed index of the batch with the given batchID, based on the state of the
 *     queue. Note this index can negative if the requested batchID has already been removed from
 *     the queue or past the end of the queue if the batchID is larger than the last added batch.
 */
- (NSInteger)indexOfBatchID:(BatchId)batchID {
  NSMutableArray<FSTMutationBatch *> *queue = self.queue;
  NSUInteger count = queue.count;
  if (count == 0) {
    // As an index this is past the end of the queue
    return 0;
  }

  // Examine the front of the queue to figure out the difference between the batchID and indexes
  // in the array. Note that since the queue is ordered by batchID, if the first batch has a larger
  // batchID then the requested batchID doesn't exist in the queue.
  FSTMutationBatch *firstBatch = queue[0];
  BatchId firstBatchID = firstBatch.batchID;
  return batchID - firstBatchID;
}

/**
 * Finds the index of the given batchID in the mutation queue and asserts that the resulting
 * index is within the bounds of the queue.
 *
 * @param batchID The batchID to search for
 * @param action A description of what the caller is doing, phrased in passive form (e.g.
 *     "acknowledged" in a routine that acknowledges batches).
 */
- (NSUInteger)indexOfExistingBatchID:(BatchId)batchID action:(NSString *)action {
  NSInteger index = [self indexOfBatchID:batchID];
  HARD_ASSERT(index >= 0 && index < self.queue.count, "Batches must exist to be %s", action);
  return (NSUInteger)index;
}

- (size_t)byteSizeWithSerializer:(FSTLocalSerializer *)serializer {
  size_t count = 0;
  for (FSTMutationBatch *batch in self.queue) {
    count += [[serializer encodedMutationBatch:batch] serializedSize];
  };
  return count;
}

@end

NS_ASSUME_NONNULL_END
