//
//  LoginViewController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/18.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // inputView
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        //基本的にAutoLayoutはTrueになっているためViewのFrame設定しても効かない
        //viewのframeを設定するにはAutoLayoutをfalseする
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true
        return view
    }()
    
    // 登録ボタン
    lazy var registerButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        return button
    }()
    
    func handleRegister() {
        
        guard let email = emailTextfield.text , let password = passwordTextfield.text , let name = nameTextfield.text else {
            
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            //Successfully Authenticated user
            let ref = FIRDatabase.database().reference(fromURL: "https://chatfirebase-5b8fc.firebaseio.com/")
            
            let userRef = ref.child("users").child(uid)
            
            let values = ["name": name , "email": email]
            
            userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                print("Successfully saved into Firebase db")
                
                
            })
            
        })
        
        
    }
    
    // name 入力欄
    let nameTextfield: UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // email 入力欄
    let emailTextfield: UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // password 入力欄
    let passwordTextfield: UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "login")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)
        
        setInputContainerView()
        setRegisterButton()
        setProfileImageView()
    }
    
    func setProfileImageView() {
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setInputContainerView() {
        // x, yの座標を設定
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // width, heightを設定
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        inputContainerView.addSubview(nameTextfield)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextfield)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextfield)
        inputContainerView.addSubview(passwordSeparatorView)
        
        // nameTextfield *********************************************************************
        // x, yの座標を設定
        // leftから12離れて配置
        nameTextfield.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextfield.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextfield.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1 / 3).isActive = true
        
        // x, yの座標を設定
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextfield.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: nameTextfield.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // nameTextfield *********************************************************************
        
        
        
        // emailTextfield *********************************************************************
        // x, yの座標を設定
        // leftから12離れて配置
        emailTextfield.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextfield.topAnchor.constraint(equalTo: nameTextfield.bottomAnchor).isActive = true
        emailTextfield.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1 / 3).isActive = true
        
        // x, yの座標を設定
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: emailTextfield.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // emailTextfield *********************************************************************
        
        
        // passwordTextfield *********************************************************************
        // x, yの座標を設定
        // leftから12離れて配置
        passwordTextfield.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextfield.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor).isActive = true
        passwordTextfield.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1 / 3).isActive = true
        
        // x, yの座標を設定
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextfield.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: passwordTextfield.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // passwordTextfield *********************************************************************
        
        
    }
    
    func setRegisterButton() {
        // inputContainerViewを基準に設定
        // x, topの座標を設定
        registerButton.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        
        // width, heightを設定
        registerButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    //statusBarStyleを明るい方に設定
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    //拡張でrgbInitを簡単に設定できるように新たにInitを追加
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}




