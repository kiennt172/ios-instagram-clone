//
//  MainTabVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/23/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        configViewControllers()
        
        checkUserLogin()
    }
    
    func configViewControllers() {
        
        //home feed controller
        let feedVC = constructNavController(unSelectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //search controller
        let searchVC = constructNavController(unSelectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!, rootViewController: SearchVC())
        
        //post controller
        let postVC = constructNavController(unSelectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!, rootViewController: PostVC())
        
        //notification controller
        let notificationVC = constructNavController(unSelectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!, rootViewController: NotificationVC())
        
        //profile controller
        let profileVC = constructNavController(unSelectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController: ProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        viewControllers = [feedVC, searchVC, postVC, notificationVC, profileVC]
        tabBar.tintColor = .black
    }
    
    func constructNavController(unSelectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unSelectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        return navController
    }
    
    func checkUserLogin() {
        if Auth.auth().currentUser == nil {
            print("no user")
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                loginVC.modalPresentationStyle = .fullScreen
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
            
        } else {
            print("user logined")
        }
    }
    

    

}
