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
        
        fetchUser()
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapchat) in
            
            if let dic = snapchat.value as? [String: Any] {
            
                let user = User()
                user.setValuesForKeys(dic)
                
                print("\(user.name!),\(user.email!)")
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
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        //cell.textLabel?.text = users["name"] as? String
        
        
        return cell
    }
}
