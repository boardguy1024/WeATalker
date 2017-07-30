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
    
    let cellId = "cellId"
    var messageContrlller: MessageController?
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = ubanBlueColor
        navigationController?.navigationBar.tintColor = .white
        let customFont = UIFont(name: "Chalkboard SE", size: 17.0)!
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: customFont], for: .normal)

        //Logoutボタンを左上に配置
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //Charボタンを右上に配置
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Friends List", style: .plain, target: self, action: #selector(handleNewMessage))
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //ユーザーのログイン状態をチェック
        checkIfUserIsLoggedIn()
        
    }
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            ref.child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId: String) {
        let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messageRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
            
            if let dic = messageSnapshot.value as? [String: Any] {
                
                let message = Message(dictionary: dic)
                
                //各セルにユーザーが重複されないように制御（結果的に各ユーザーは最後のメッセージを表示することになる）
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
        })
    }
    
    private func attemptReloadOfTable() {
        //tableView reloadを無効化
        self.timer?.invalidate()
        //この処理は無効化されるが、最後のループのみ実行されるのでtableView Reloadは１回のみ実行される
        //(intervalによって少し変動)
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.handleReloadTableView), userInfo: nil, repeats: false)
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sort(by: { (message1, message2) -> Bool in
          
            if let timeStamp1 = message1.timeStamp, let timeStamp2 = message2.timeStamp {
              return timeStamp1 > timeStamp2
            }
            return false
        })
    }
    
    func handleReloadTableView() {
        DispatchQueue.main.async {
            print("tableView reloaded")
            self.tableView.reloadData()
        }
    }
    
    func handleNewMessage() {
        
   
        // レイアウト作成
        let flowLayout = UICollectionViewFlowLayout()
        
        let cellSize = view.frame.width / 2 - 5.0
        flowLayout.itemSize = CGSize(width: cellSize , height: cellSize)
        
        let newMessageController = NewMessageController(collectionViewLayout: flowLayout)
        
        newMessageController.messageController = self
        
        //self.navigationController?.pushViewController(newMessageController, animated: true)
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
        //初期化
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        //userのメッセージを取得後、tableViewをreload
        observeUserMessages()
        
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
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textColor = .white
        nameLabel.font = UIFont(name: "Chalkboard SE", size: 20)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    //ChatContoller表示
    func showChatController(user: User) {
        
        // レイアウト作成
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 50 , height: 50)
        
        let chatLogController = ChatLogController(collectionViewLayout: flowLayout)
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        
        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            
            self.showChatController(user: user)
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
















