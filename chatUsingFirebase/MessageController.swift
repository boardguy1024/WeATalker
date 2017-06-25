//
//  ViewController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/18.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Logoutボタンを左上に配置
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //Charボタンを右上に配置
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(handleNewMessage))
        
        //ユーザーのログイン状態をチェック
        checkIfUserIsLoggedIn()
    }
    
    func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        let navController = UINavigationController.init(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        // user is not logged inf
        if FIRAuth.auth()?.currentUser?.uid == nil {
            handleLogout()
        } else {
            //ユーザーがログイン状態なのでDBからユーザー情報をfetchする
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    let name = dictionary["name"] as? String
                    self.navigationItem.title = name
                }
                
                
                
                
            })
        }
        
    }
    
    func handleLogout() {
        
        //現在のアクセスしているユーザーがログインしていない場合にはサインアウトをおこなう
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error  {
            print(error)
        }
        
        let loginController = LoginViewController()
        present(loginController, animated: true, completion: nil)
    }
}

