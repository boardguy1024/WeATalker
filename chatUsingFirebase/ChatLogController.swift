//
//  ChatLogController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/02.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController , UITextFieldDelegate , UICollectionViewDelegateFlowLayout,
UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
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
        guard let toId = user?.id else { return }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        //user-messageを取得
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            //該当するmessageを取得
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
                
                guard let dictionary = messageSnapshot.value as? [String: Any] else { return }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
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
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //スクロール領域もcontentInsetに合わせる
        //        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //keyboardの操作をinterectivityする
        collectionView?.keyboardDismissMode = .interactive
        
        //
        //        setupKeyboardObservers()
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGray
        containerView.addSubview(separatorView)
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "image.png")
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.tintColor = .lightGray
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        containerView.addSubview(uploadImageView)
        
        //constraint
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
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
        
        containerView.addSubview(self.inputTextfield)
        
        //constraint
        self.inputTextfield.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextfield.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextfield.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextfield.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        return containerView
    }()
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //MARK: -UIPickerView Delegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
        
        print("We selected an image!!")
    }
    
    //選択したイメージをFirebaseのストレージに保存する
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message-images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if error != nil {
                    print("Failed to upload image " , error!)
                    return
                }
                
                //storageに保存したimageのurlを取得
                if let imageUrl = metaData?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl: imageUrl)
                }
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String) {
        let ref = FIRDatabase.database().reference().child("messages")
        //messageの中に chileの uidを生成
        let childRef = ref.childByAutoId()
        //相手Userのuidを取得
        guard let toId = user?.id else { return }
        //LoginUserのuidを取得
        guard let fromId = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let timeStamp = String(Date().timeIntervalSince1970)
        let values = ["imageUrl": imageUrl, "toId": toId , "fromId": fromId, "timeStamp": timeStamp]
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let messageId = childRef.key
            //送信者
            //送信するメッセージValueを user-messageの中に送信者uid名でdatabaseにUpdateする。
            let userMessageRef =  FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            userMessageRef.updateChildValues([messageId: 1])
            
            //受信者
            //送信するメッセージValueを user-messageの中に受信者uid名でdatabaseにUpdateする。
            let recipientMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientMessageRef.updateChildValues([messageId: 1])
            
        }
        
    }
    
    //UIViewControllerのpropertyの一つ
    //keyBoardの上部に追加できるaccessoryView
    override var inputAccessoryView: UIView? {
        get {
            
            return inputContainerView
        }
    }
    //自動的にテキストフィールドを出す
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //画面が破棄される時、必ずnotification observerを削除すること
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupKeyboardObservers() {
        
        //メッセージ送信欄の位置をキーボードの上に動的に表示するためにnotificationを登録
        NotificationCenter.default.addObserver(self, selector: #selector(handlekeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlekeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handlekeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
        containerViewButtomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    func handlekeyboardWillHide(notification: Notification) {
        guard let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
        containerViewButtomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    //このアプリではlandScapeモードは対応しないが、念のため入れておく
    //サイズ変更によるcollectionViewレイアウト更新
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    var containerViewButtomAnchor: NSLayoutConstraint?
    
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
            let userMessageRef =  FIRDatabase.database().reference().child("user-messages").child(fromUserId).child(toUserId)
            userMessageRef.updateChildValues([messageId: 1])
            
            //受信者
            //送信するメッセージValueを user-messageの中に受信者uid名でdatabaseにUpdateする。
            let recipientMessageRef = FIRDatabase.database().reference().child("user-messages").child(toUserId).child(fromUserId)
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
        //テキストではなくイメージを送れることになるのでテキストを取得できた場合のみwidthを調整する
        if let message = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message).width + 25
        }
        
        return cell
    }
    
    //cellをセットする
    private func setupCellwithColor(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
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
        
        //ImageUrlを表示しない時はmessageImageViewを隠す
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
            cell.bubbleView.isHidden = false
        }

        
    }
    
    
    
    //MARK:- collectionViewLayoutFlow Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        //view.frame.widthを使用するとdevice向きが変わってもこの値は変わらないので吹き出し位置が崩れてしまう。
        //screen.bounce.widthを使うことで動的に正しいwidthが取得できる
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
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









