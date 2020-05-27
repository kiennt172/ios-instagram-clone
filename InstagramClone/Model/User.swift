//
//  User.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/26/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

class User {
    var uid: String!
    var name: String!
    var username: String!
    var profileImageUrl: String!
    
    init(uid: String, data: Dictionary<String, AnyObject>) {
        self.uid = uid
        
        if let name = data["name"] as? String {
            self.name = name
        }
        
        if let username = data["username"] as? String {
            self.username = username
        }
        
        if let profileImageUrl = data["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
}
