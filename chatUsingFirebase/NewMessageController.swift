//
//  NewMessageController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/22.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UICollectionViewController , UICollectionViewDelegateFlowLayout , UINavigationControllerDelegate {
    
    let cellId = "cellId"
    var users = [User]()
    var messageController: MessageController?
    
    let backgroundImageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.image = UIImage(named: "new_background.jpg")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundView = backgroundImageView
        setBackgroundImageView()
        
        navigationItem.title = "Friends list"
        navigationController?.navigationBar.titleTextAttributes
            = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 20)!]
        navigationController?.navigationBar.barTintColor = ubanBlueColor
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(handleCancel))
        
        collectionView?.register(UserCollectionCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func setBackgroundImageView() {
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    //DBにあるUser情報を取得する
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapchat) in
            
            if let dic = snapchat.value as? [String: Any] {
                
                let user = User()
                user.id = snapchat.key
                user.setValuesForKeys(dic)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- collectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserCollectionCell
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        
        if let profileImageUrl = user.profileImageUrl {
            
            print("user image name is :\(user.name!) and user url is :\(profileImageUrl)")
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            
            cell.transform = CGAffineTransform(scaleX: 0.3, y: 2)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
                
            }, completion: nil)

        }
        return cell

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            
            //chatControllerを表示させる。
            self.messageController?.showChatController(user: user)
        }
    }
 }



















