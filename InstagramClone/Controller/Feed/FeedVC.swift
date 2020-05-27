//
//  FeedVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/23/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController {

    
    // MARK: - Properties
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        configLogoutButton()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    // MARK: - Handle
    func configLogoutButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutPressed))
    }
    
    @objc func logoutPressed() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                
                let loginVC = LoginVC()
                loginVC.modalPresentationStyle = .fullScreen
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
                print("logout success")
            } catch {
                print("error logout")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    

}
