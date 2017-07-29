//
//  LoginViewController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/18.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    var messageController: MessageController?
    
    // inputView
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.9
        //基本的にAutoLayoutはTrueになっているためViewのFrame設定しても効かない
        //viewのframeを設定するにはAutoLayoutをfalseする
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    // 登録ボタン
    lazy var registerButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(r: 237, g: 167, b: 0)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    func handleLoginRegister() {
        
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        //入力バリデーションをチェック
        if !checkValidInputForLoginOrRegister() {
            return
        }
        
        guard let email = emailTextfield.text, let password = passwordTextfield.text else {
            print("Form is not vaild")
            return
        }
        
        SVProgressHUD.show()
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                print(error!)
                self.showAlertView(title: "ログインに失敗しました", message: "")
                SVProgressHUD.dismiss()
                return
            }
            
            self.messageController?.checkIfUserIsLoggedIn()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // name 入力欄
    let nameTextfield: UITextField = {
        
        let tf = UITextField()
        tf.attributedPlaceholder =
            NSAttributedString(string:"Name", attributes:[NSForegroundColorAttributeName: UIColor.init(r: 130, g: 220, b: 220),NSFontAttributeName :UIFont(name: "Arial", size: 16)!])

        tf.returnKeyType = .done
        tf.textColor = greenColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(r: 130, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // email 入力欄
    let emailTextfield: UITextField = {
        
        let tf = UITextField()
        tf.attributedPlaceholder =
            NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName: UIColor.init(r: 130, g: 220, b: 220),NSFontAttributeName :UIFont(name: "Arial", size: 16)!])
        tf.textColor = greenColor
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(r: 130, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // password 入力欄
    let passwordTextfield: UITextField = {
        
        let tf = UITextField()
        tf.attributedPlaceholder =
            NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor.init(r: 130, g: 220, b: 220),NSFontAttributeName :UIFont(name: "Arial", size: 16)!])

        tf.textColor = greenColor
        tf.returnKeyType = .done
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(r: 130, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let logoImageview: UIImageView = {
       
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        //タブジェスチャーを追加する
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        
        return imageView
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background.jpg")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var loginRegisterSegmentControl: UISegmentedControl = {
        
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        sc.layer.cornerRadius = 15
        sc.layer.masksToBounds = true
        sc.layer.borderWidth = 1
        sc.layer.borderColor = UIColor.white.cgColor
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    //セグメントを選択した時に呼ばれる
    func handleLoginRegisterChange() {
        
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        
        nameTextfield.text = ""
        emailTextfield.text = ""
        passwordTextfield.text = ""
        
        //選択によって入力欄の高さを調整
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            inputsContainerViewHeightAnchor?.constant = 100
            nameTextfield.isHidden = true
            logoImageview.isHidden = false
            profileImageView.isHidden = true
            logoImageview.transform = CGAffineTransform(scaleX: 0.3, y: 2)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.logoImageview.transform = CGAffineTransform.identity
            }, completion: nil)
        } else {
            inputsContainerViewHeightAnchor?.constant = 150
            nameTextfield.isHidden = false
            logoImageview.isHidden = true
            profileImageView.isHidden = false
            profileImageView.transform = CGAffineTransform(scaleX: 0.3, y: 2)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.profileImageView.transform = CGAffineTransform.identity
            }, completion: nil)

        }
        
        //nameTextfield高さを変更
        nameTextfieldHeightAnchor?.isActive = false
        nameTextfieldHeightAnchor = nameTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextfieldHeightAnchor?.isActive = true
        
        emailTextfieldHeightAnchor?.isActive = false
        emailTextfieldHeightAnchor = emailTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextfieldHeightAnchor?.isActive = true
        
        passwordTextfieldHeightAnchor?.isActive = false
        passwordTextfieldHeightAnchor = passwordTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextfieldHeightAnchor?.isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        view.addSubview(backgroundImageView)
        view.addSubview(inputContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentControl)
        view.addSubview(logoImageview)
        
        setBackgroundImageView ()
        setInputContainerView()
        setRegisterButton()
        setProfileImageView()
        setLogRegisterSegmentControl()
        setLogoImageView()
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTabScreen)))
    }
    
    func handleTabScreen() {
        self.view.endEditing(true)
    }

    func setBackgroundImageView() {
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func setLogRegisterSegmentControl() {
        loginRegisterSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterSegmentControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setProfileImageView() {
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setLogoImageView() {
        logoImageview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageview.bottomAnchor.constraint(lessThanOrEqualTo: loginRegisterSegmentControl.topAnchor, constant: -50).isActive = true
        logoImageview.widthAnchor.constraint(equalToConstant: 370).isActive = true
        logoImageview.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextfieldHeightAnchor: NSLayoutConstraint?
    var emailTextfieldHeightAnchor: NSLayoutConstraint?
    var passwordTextfieldHeightAnchor: NSLayoutConstraint?
    
    func setInputContainerView() {
        // x, yの座標を設定
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // width, heightを設定
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive = true
        
        inputsContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
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
        
        nameTextfieldHeightAnchor = nameTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1 / 3)
        nameTextfieldHeightAnchor?.isActive = true
        
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
        
        
        emailTextfieldHeightAnchor = emailTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextfieldHeightAnchor?.isActive = true
        
        
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
        passwordTextfieldHeightAnchor = passwordTextfield.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextfieldHeightAnchor?.isActive = true
        
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






