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
    var timeStamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String? {
        
        //現在ログイン中のcurrentUser.uid と 取得したmessageのfromIdが一致した場合のみ、message.toidをセットする
        return  fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
       }
}
