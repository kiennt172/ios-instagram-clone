//
//  ProfileHeader.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/25/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase

class ProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
            
            checkUser()
            let fullName = user?.name
            nameLabel.text = fullName
            
            profileImage.loadImage(with: (user?.profileImageUrl)!)
        }
    }
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 1
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let postLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let attributeText = NSMutableAttributedString(string: "6\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributeText.append(NSAttributedString(string: "Posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributeText
        label.textColor = .black
        return label
    }()
    
    let followerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let attributeText = NSMutableAttributedString(string: "6\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributeText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributeText
        label.textColor = .black
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let attributeText = NSMutableAttributedString(string: "6\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributeText.append(NSAttributedString(string: "Following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributeText
        label.textColor = .black
        return label
    }()
    
    let editProfileButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Edit Profile", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.5
        return btn
    }()
    
    let followButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Follow", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.blue
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.5
        return btn
    }()
    
    let messageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Message", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.5
        return btn
    }()
    
    let gridButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "grid"), for: .normal)
        return btn
    }()
    
    let listButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    let bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        addSubview(profileImage)
        profileImage.anchor(top: topAnchor, right: nil, bottom: nil, left: leftAnchor, paddingTop: 10, paddingRight: 0, paddingBottom: 0, paddingLeft: 20, width: 80, height: 80)
        profileImage.layer.cornerRadius = 80 / 2
        
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImage.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, paddingTop: 10, paddingRight: 20, paddingBottom: 0, paddingLeft: 20, width: 0, height: 0)
        
        configUserStats()
        configButtonToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postLabel, followerLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: nil, right: rightAnchor, bottom: nil, left: profileImage.rightAnchor, paddingTop: 0, paddingRight: 20, paddingBottom: 0, paddingLeft: 20, width: 0, height: 0)
        stackView.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
    }
    
    func configButtonToolbar() {
        let topDivider = UIView()
        topDivider.backgroundColor = .lightGray
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor  = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: nil, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 0, height: 50)
        
        addSubview(topDivider)
        topDivider.anchor(top: stackView.topAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 0, height: 0.5)
        
        addSubview(bottomDivider)
        bottomDivider.anchor(top: nil, right: rightAnchor, bottom: stackView.bottomAnchor, left: leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 0, height: 0.5)
    }
    
    func configOtherUserButton() {
        
        let stackView = UIStackView(arrangedSubviews: [followButton, messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        addSubview(stackView)
        stackView.anchor(top: nameLabel.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, paddingTop: 10, paddingRight: 20, paddingBottom: 0, paddingLeft: 20, width: 0, height: 30)
    }
    
    func checkUser() {
        print("zz")
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        print("check user")
        if currentUid == user.uid {
            //show profile button
            addSubview(editProfileButton)
            editProfileButton.anchor(top: nameLabel.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, paddingTop: 10, paddingRight: 20, paddingBottom: 0, paddingLeft: 20, width: 0, height: 30)
            
        } else {
            //show follow button
            configOtherUserButton()
        }
    }
    
    
    
    
}
