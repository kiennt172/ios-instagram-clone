//
//  Extension.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/21/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat, paddingRight: CGFloat, paddingBottom: CGFloat, paddingLeft: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIColor {
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha / 255)
    }
}

var imageCache = [String: UIImage]()
extension UIImageView {
    func loadImage(with urlString: String) {
        //check if image exist in cache
        if let image = imageCache[urlString] {
            self.image = image
            return
        }
        
        //if image does not exist in cache
        guard let url = URL(string: urlString) else { return }
        
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error load image ", error.localizedDescription)
            }
            
            //set image data
            guard let imageData = data else { return }
            
            //load image with data
            let photoImage = UIImage(data: imageData)
            
            //put image to cache
            imageCache[url.absoluteString] = photoImage
            
            //asyc
            DispatchQueue.main.async {
                self.image = photoImage
            }
            
            
        }.resume()
    }
}
