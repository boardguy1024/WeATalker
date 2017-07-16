//
//  ChatLogController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/02.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController , UITextFieldDelegate , UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
            
            observeMessage()
        }
    }
    
    
    
    var messages = [Message]()
    
    private func observeMessage() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        //user-messageを取得
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            //該当するmessageを取得
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
                
                guard let dictionary = messageSnapshot.value as? [String: Any] else { return }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                // チャット画面のuser idとmessageのidが一致するのみメッセージを表示する
                if message.chatPartnerId() == self.user?.id {
                    
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
 
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
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
        
        //セルをtopから8point離す, bottomから60離す
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
        //スクロール領域もcontentInsetに合わせる
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 52, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponent()
    }
    
    //このアプリではlandScapeモードは対応しないが、念のため入れておく
    //サイズ変更によるcollectionViewレイアウト更新
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupInputComponent() {
        
        let containerView = UIView()
        containerView.backgroundColor = .white
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
        
        if inputTextfield.text == "" { return }
        
        let ref = FIRDatabase.database().reference().child("messages")
        
        let childRef = ref.childByAutoId()
        
        guard let toUserId = user?.id else { return }
        guard let fromUserId = FIRAuth.auth()?.currentUser?.uid else { return }
        let timeStamp = String(Date().timeIntervalSince1970)
        let value = ["text": inputTextfield.text!, "toId": toUserId , "fromId": fromUserId, "timeStamp": timeStamp]
        
        childRef.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            //メッセージがupdataできたのみ打ち込んだメッセージを削除
            self.inputTextfield.text = nil
            
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
    
    //MARK:- collectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.row]
        
        cell.textView.text = message.text
        
        setupCellwithColor(cell: cell, message: message)
        
        //25でwidthを微調整
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 25
        
        return cell
    }
    
    private func setupCellwithColor(cell: ChatMessageCell, message: Message) {
       
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            //自分のメッセージ
            cell.bubbleView.backgroundColor = blueColor
            cell.textView.textColor = .white
            cell.bubbleleftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
        } else {
            //相手のメッセージ
            cell.bubbleView.backgroundColor = grayColor
            cell.textView.textColor = .darkGray
            cell.bubbleleftAnchor?.isActive = true
            cell.bubbleRightAnchor?.isActive = false
            cell.profileImageView.isHidden = false
        }

    }
    
    //MARK:- collectionViewLayoutFlow Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        if let text = messages[indexPath.row].text {
          height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return  NSString(string: text).boundingRect(with: size, options: options , attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    //MARK:- textField Delegate Methods
    
    //textFieldでreturnキーが押下した際、呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        return true
    }
}














