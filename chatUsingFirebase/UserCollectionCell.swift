//
//  UserCollectionCell.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/29.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class UserCollectionCell: UICollectionViewCell {
 
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
        }
    }
    
    let nameLabel: UILabel = {
        
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont(name: "Chalkboard SE", size: 16)
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = darkBlueColor
        return lb
    }()

    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            
            let ref = FIRDatabase.database().reference().child("users").child(id)
            
            ref.observe(.value, with: { (snapshot) in
                
                if let dic = snapshot.value as? [String: Any] {
                    
                    self.nameLabel.text = dic["name"] as? String
                    
                    if let profileImageUrl = dic["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    let profileImageView: UIImageView =  {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        
        //profileImageView constraint
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //textView constraint
        nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: frame.width - 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}







