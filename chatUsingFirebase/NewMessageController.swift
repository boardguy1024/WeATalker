//
//  NewMessageController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/22.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    //DBにあるUser情報を取得する
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapchat) in
            
            if let dic = snapchat.value as? [String: Any] {
                
                let user = User()
                user.id = snapchat.key
                user.setValuesForKeys(dic)
                self.users.append(user)
                
                // users 모델에 퓃치한 데이터를 때려박을때마다 테이블 뷰를 리로드 한다.
                // 그런데 여기는 메인스레드가 아니다 그러므로 크래쉬가 일어난다.
                //self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        })
        
        
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        
        if let profileImageUrl = user.profileImageUrl {
            
            print("user image name is :\(user.name!) and user url is :\(profileImageUrl)")
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            
        }
        return cell
    }
    
    var messageController: MessageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) { 
            
            let user = self.users[indexPath.row]

            //chatControllerを表示させる。
            self.messageController?.showChatController(user: user)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}



















