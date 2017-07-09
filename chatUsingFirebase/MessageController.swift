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
    
    var messageContrlller: MessageController?
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Logoutボタンを左上に配置
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //Charボタンを右上に配置
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(handleNewMessage))
        
        //ユーザーのログイン状態をチェック
        checkIfUserIsLoggedIn()
        
        observeMessages()
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dic = snapshot.value as? [String: Any] {
                
                let message = Message()
                
                message.setValuesForKeys(dic)
                
                self.messages.append(message)
            }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        
        newMessageController.messageController = self
        
        let navController = UINavigationController.init(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        // user is not logged inf
        if FIRAuth.auth()?.currentUser?.uid == nil {
            handleLogout()
        } else {
            fetchUserAndSetupNavBarTitle()
        }
        
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        //ユーザーがログイン状態なのでDBからユーザー情報をfetchする
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                let user = User()
                user.setValuesForKeys(dictionary)
                
                self.setupNavBarWithUser(user: user)
                
            }
        })
    }
    
    func setupNavBarWithUser(user: User) {
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(profileImageView)
        //ios9 constraint anchor
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        let nameLable = UILabel()
        nameLable.text = user.name
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLable)
        
        nameLable.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLable.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLable.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLable.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    //ChatContoller表示
    func showChatController(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    
    func handleLogout() {
        
        //現在のアクセスしているユーザーがログインしていない場合にはサインアウトをおこなう
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error  {
            print(error)
        }
        
        let loginController = LoginViewController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let message = messages[indexPath.row]
        
        if let toId = message.toId {
            
            let ref = FIRDatabase.database().reference().child("users").child(toId)
        
            ref.observe(.value, with: { (snapshot) in
                
                if let dic = snapshot.value as? [String: Any] {
                    
                    cell.textLabel?.text = dic["name"] as? String
                }
                
            }, withCancel: nil)
            
        }
        
        
        //cell.textLabel?.text = messages[indexPath.row].toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
}
















