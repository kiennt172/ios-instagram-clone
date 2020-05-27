//
//  LoginVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/21/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    let logoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgba(red: 0, green: 120, blue: 175, alpha: 255)
        
        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "Instagram_logo_white")
        logoImage.contentMode = .scaleAspectFit
        view.addSubview(logoImage)
        logoImage.anchor(top: nil, right: nil, bottom: nil, left: nil, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 200, height: 50)
        logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
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
    
    let loginButton: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.rgba(red: 149, green: 204, blue: 244, alpha: 255)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        return btn
    }()
    
    let dontHaveAccount: UIButton = {
        let btn = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgba(red: 17, green: 154, blue: 237, alpha: 255)]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        return btn
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //set background
        view.backgroundColor = UIColor.white
        
        //hide navigationcontroller
        navigationController?.navigationBar.isHidden = true
        
        
        view.addSubview(logoContainer)
        logoContainer.anchor(top: view.topAnchor, right: view.rightAnchor, bottom: nil, left: view.leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 0, height: 150)
        
        configViewcomponent()
        
        view.addSubview(dontHaveAccount)
        dontHaveAccount.anchor(top: nil, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, paddingLeft: 0, width: 0, height: 50)
        

    }
    
    func configViewcomponent() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainer.bottomAnchor, right: view.rightAnchor, bottom: nil, left: view.leftAnchor, paddingTop: 20, paddingRight: 40, paddingBottom: 0, paddingLeft: 40, width: 0, height: 140)
    }
    
    @objc func signUpPressed() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func validateForm() {
        guard emailTextField.hasText, passwordTextField.hasText else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgba(red: 149, green: 204, blue: 244, alpha: 255)
            return
        }
        
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor.rgba(red: 17, green: 154, blue: 237, alpha: 255)
    }
    
    @objc func loginPressed() {
        //properties
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Login fail", error.localizedDescription)
                return
            }
            
            print("login success")
            
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            guard let mainTabVC = window!.rootViewController as? MainTabVC else { return }
            mainTabVC.configViewControllers()
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    



}
