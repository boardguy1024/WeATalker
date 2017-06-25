//
//  User.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/22.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var email: String?
    var profileImageUrl: String?
}

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
