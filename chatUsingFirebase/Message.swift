//
//  Message.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/09.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromId: String?
    var text: String?
    var timeStamp: String?
    var toId: String?
    
    var imageUrl: String?
    
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
        
        //現在ログイン中のcurrentUser.uid と 取得したmessageのfromIdが一致した場合のみ、message.toidをセットする
        return  fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
       }
    
    init(dictionary: [String: Any]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? String
        toId = dictionary["toId"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        
    }
}
