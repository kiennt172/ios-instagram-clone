//
//  SearchUserCell.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/26/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {
    
    var user: User? {
        didSet {
            profileImage.loadImage(with: (user?.profileImageUrl)!)
            textLabel?.text = user?.name
            detailTextLabel?.text = user?.username
        }
    }
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        return image
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        //add profile image
        addSubview(profileImage)
        profileImage.anchor(top: nil, right: nil, bottom: nil, left: leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 12, width: 48, height: 48)
        profileImage.layer.cornerRadius = 24
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.textLabel?.text = "Username"
        self.detailTextLabel?.text = "full name"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //set label frame
        textLabel?.frame = CGRect(x: 68, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: (detailTextLabel?.frame.origin.y)! - 2, width: frame.width - 108, height: (detailTextLabel?.frame.height)!)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = UIColor.lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
