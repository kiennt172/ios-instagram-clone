//
//  SearchVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/23/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase

private let searchCellId = "searchCellId"
class SearchVC: UITableViewController {
    
    let db = Firestore.firestore()
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: searchCellId)
        
        configTitle()
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 0)
        
        fetchUser()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId, for: indexPath) as! SearchUserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.userFromSearch = user
        
        navigationController?.pushViewController(profileVC, animated: true)
    }

    
    // MARK: - func
    func configTitle() {
        self.navigationItem.title = "Explore"
    }
    
    // MARK: - API
    func fetchUser() {
        db.collection("users").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("error: ", error.localizedDescription)
            } else {
                self.users = []
                if let snapshot = snapshot?.documents {
                    for document in snapshot {
                        let data = document.data() as Dictionary<String, AnyObject>
                        
                        let user = User(uid: document.documentID, data: data)
                        self.users.append(user)
                        
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                    
                }
            }
            
        }
    }
    

}
