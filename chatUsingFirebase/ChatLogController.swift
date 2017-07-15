//
//  ChatLogController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/02.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController , UITextFieldDelegate{
    
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
        }
    }
    
    lazy var inputTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Enter message..."
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.delegate = self
        return textfield
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationItem.title = "Chat Log Controller"
        collectionView?.backgroundColor = .white
        setupInputComponent()
    }
    
    func setupInputComponent() {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //constraint
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGray
        containerView.addSubview(separatorView)
        
        //constraint
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        //constraint
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextfield)
        
        //constraint
        inputTextfield.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextfield.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextfield.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextfield.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    }
    
    // sendボタンを押下するとメッセージ関連情報をdatabaseにupdateする。
    func handleSend() {
        
        let ref = FIRDatabase.database().reference().child("messages")
        
        let childRef = ref.childByAutoId()
        
        guard let toUserId = user?.id else { return }
        guard let fromUserId = FIRAuth.auth()?.currentUser?.uid else { return }
        let timeStamp = String(Date().timeIntervalSince1970)
        let value = ["text": inputTextfield.text!, "toId": toUserId , "fromId": fromUserId, "timeStamp": timeStamp]
        
        //childRef.updateChildValues(value)
        
        childRef.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let messageId = childRef.key
            //送信者
            //送信するメッセージValueを user-messageの中に送信者uid名でdatabaseにUpdateする。
            let userMessageRef =  FIRDatabase.database().reference().child("user-messages").child(fromUserId)
            userMessageRef.updateChildValues([messageId: 1])
            
            //受信者
            //送信するメッセージValueを user-messageの中に受信者uid名でdatabaseにUpdateする。
            let recipientMessageRef = FIRDatabase.database().reference().child("user-messages").child(toUserId)
            recipientMessageRef.updateChildValues([messageId: 1])
        }
        
        
    }
    
    //MARK:- Delegate Methods
    
    //textFieldでreturnキーが押下した際、呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        return true
    }
}














