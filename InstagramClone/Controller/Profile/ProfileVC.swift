//
//  ProfileVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/23/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerId = "HeaderCell"

class ProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let db = Firestore.firestore()
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        //fetch data
        fetchCurrentUserData()

    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 220)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ProfileHeader
        
        let uid = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(uid!)
        docRef.getDocument { (snapshot, error) in
            guard let data = snapshot?.data() as Dictionary<String, AnyObject>? else { return }
            let user = User(uid: uid!, data: data)
            
            header.user = user
            
            self.navigationItem.title = user.username
        }
        return header
        
    }
    
    // MARK: - API
    func fetchCurrentUserData() {
        
        

    }

    

}
