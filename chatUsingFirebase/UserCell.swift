//
//  UserCell.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/09.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            if let toId = message?.toId {
                
                let ref = FIRDatabase.database().reference().child("users").child(toId)
                
                ref.observe(.value, with: { (snapshot) in
                    
                    if let dic = snapshot.value as? [String: Any] {
                        
                        self.textLabel?.text = dic["name"] as? String
                        
                        if let profileImageUrl = dic["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        }
                    }
                    
                }, withCancel: nil)
            }
            detailTextLabel?.text = message?.text
            
            if let second = message?.timeStamp?.doubleValue {
                let timeStampDate = Date(timeIntervalSince1970: second)
                
                let dateFommater = DateFormatter()
                dateFommater.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFommater.string(from: timeStampDate)
            }
            
        }
    }
    
    let profileImageView: UIImageView =  {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "HH:MM:SS"
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
