//
//  SignUpVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/21/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class SignUpVC: UIViewController {
    
    var imageSelected = false
    
    let plusPhotoButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(profileImagePicker), for: .touchUpInside)
        return btn
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return tf;
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return tf;
    }()
    
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fullname"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return tf;
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return tf;
    }()
    
    let signUpButton: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.rgba(red: 149, green: 204, blue: 244, alpha: 255)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        return btn
    }()
    
    let alreadyHaveAccount: UIButton = {
        let btn = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Login", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgba(red: 17, green: 154, blue: 237, alpha: 255)]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, right: nil, bottom: nil, left: nil, paddingTop: 40, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        configViewcomponent()
        
        view.addSubview(alreadyHaveAccount)
        alreadyHaveAccount.anchor(top: nil, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 0, height: 50)

    }
    
    func configViewcomponent() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, fullnameTextField,  passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, right: view.rightAnchor, bottom: nil, left: view.leftAnchor, paddingTop: 20, paddingRight: 40, paddingBottom: 0, paddingLeft: 40, width: 0, height: 240)
    }
    
    
    // MARK: OBJC func
    @objc func loginPressed() {
        //switch to loginvc
        navigationController?.popViewController(animated: true)
    }
    
    @objc func signUpPressed() {
        //signup logic
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let username = usernameTextField.text else {return}
        guard let fullname = fullnameTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("sign up error: ", error.localizedDescription)
                return
            }
            
            
            //set profile image
            guard let profileImage = self.plusPhotoButton.imageView?.image else { return }
            
            //update data
            guard let updateData = profileImage.jpegData(compressionQuality: 1) else { return }
            
            //place image in firestore
            let fileName = NSUUID().uuidString
            
            let imageReference = Storage.storage().reference().child("profile_images").child(fileName)
            
            imageReference.putData(updateData, metadata: nil) { (metadata, error2) in
                if let e = error2 {
                    print("Fail to update image", e.localizedDescription)
                }
                
                imageReference.downloadURL { (url, error) in
                    
                    
                    let dataReference = Firestore.firestore().collection("users").document((user?.user.uid)!)
                    
                    let profileImageURLString = url?.absoluteString
                    
                    let dicValue = [
                        "name": fullname,
                        "username": username.lowercased(),
                        "profileImageUrl": profileImageURLString!
                        ]
                    
                    
                    dataReference.setData(dicValue) { (error) in
                        if let error = error  {
                            print("error ", error.localizedDescription)
                            return
                        }
                        
                        print("success")
                    }
                    
                    
                }
                
                
            }
        }
    }
    
    @objc func validateForm() {
        guard emailTextField.hasText,
            passwordTextField.hasText,
            usernameTextField.hasText,
            fullnameTextField.hasText,
            imageSelected
        else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgba(red: 149, green: 204, blue: 244, alpha: 255)
            return
        }
        
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor.rgba(red: 17, green: 154, blue: 237, alpha: 255)
    }
    
    @objc func profileImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }

}

extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //setlect image
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage  else {
            imageSelected = false
            return
            
        }
        
        imageSelected = true
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor.rgba(red: 17, green: 154, blue: 237, alpha: 255)
        
        //config
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
}
