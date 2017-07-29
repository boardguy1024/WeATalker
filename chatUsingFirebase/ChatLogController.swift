//
//  ChatLogController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/02.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
            
            //FIRDataEventTypeを.Valueにすることにより、なにかしらの変化があった時に、実行しCollectionViewをReload
            messageRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
                
                guard let dictionary = messageSnapshot.value as? [String: Any] else { return }
                
                //updateされたメッセージをDatabaseから取得し、messegeにappend
                self.messages.append(Message(dictionary: dictionary)
                )
                
                //collectionView更新
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //Index path for scroll to the last index
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        //scroll positionはbottomに設定
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                        
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
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //スクロール領域もcontentInsetに合わせる
        //        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //keyboardの操作をinterectivityする
        collectionView?.keyboardDismissMode = .interactive
        
        //keyboardのobserverを設定
        setupKeyboardObservers()
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
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //MARK: -UIPickerView Delegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //Movie選択
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            print("movie file url: \(videoUrl)")
            
            let fileName = "someFileName.mov"
            FIRStorage.storage().reference().child(fileName).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                if let storageUrl = metadata?.downloadURL()?.absoluteString {
                    print(storageUrl)
                }
            })
            
            
            return
        }
        
        
        //イメージ選択
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
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
            })
        }
    }
    
    
    private func sendMessageWithImageUrl(imageUrl: String , image: UIImage) {
        
        let values: [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        
        sendMessageWithProperies(properies: values)
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
    
    //キーボードにObserverを追加
    //最後のメッセージに自動スクロールさせる
    private func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlekeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    func handlekeyboardDidShow() {
        
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        
        
        let value: [String: Any] = ["text": inputTextfield.text!]
        
        sendMessageWithProperies(properies: value)
        
        inputTextfield.text = nil
    }
    
    private func sendMessageWithProperies(properies: [String: Any]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        //messageの中に chileの uidを生成
        let childRef = ref.childByAutoId()
        //相手Userのuidを取得
        guard let toId = user?.id else { return }
        //LoginUserのuidを取得
        guard let fromId = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let timeStamp = String(Date().timeIntervalSince1970)
        var values: [String: Any] = ["toId": toId , "fromId": fromId, "timeStamp": timeStamp]
        
        //append properties dictionary
        properies.forEach({values[$0] = $1})
        
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
    
    //MARK:- collectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.row]
        
        cell.textView.text = message.text
        
        setupCellwithColor(cell: cell, message: message)
        
        //25でwidthを微調整
        //テキストではなくイメージを送れることになるのでテキストを取得できた場合のみwidthを調整する
        if let message = message.text {
            cell.textView.isHidden = false
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message).width + 25
        } else if message.imageUrl != nil {
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 200
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
        
        let message = messages[indexPath.row]
        
        //テキストの場合
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
            
            //イメージの場合、
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 == h2 / w2
            // h1 == h2 / w2 * w1
            // width 200固定の比率で高さをestimateする
            height = CGFloat(imageHeight / imageWidth * 200)
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
    
    var startingImageViewFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    //イメージをタップすることでその位置から拡大して表示させる
    func performZoomInForStaringImageView(startingImageView: UIImageView) {
        
        //タップしたimageViewのrectをsuperViewからのrectをreturn
        startingImageViewFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImageView = startingImageView
        let zoomingImageView = UIImageView(frame: startingImageViewFrame!)
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.image = startingImageView.image
        
        //keyWindowは最近makeKeyAndVisible ()が呼ばれたWindowsの配列のwindow(要は表示中のUIWindow)
        //keyWindowは?なので以下にガードをかける
        if let keyWindow = UIApplication.shared.keyWindow {
            
            startingImageView.isHidden = true
            blackBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height))
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            //拡大前の比率で高さを求める
            let zoomHeight = CGFloat((startingImageView.frame.height / startingImageView.frame.width) * keyWindow.frame.width)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: zoomHeight)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        guard let zoomOutImageView = tapGesture.view else { return }
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            zoomOutImageView.frame = self.startingImageViewFrame!
            self.blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 1
            
        }) { (completed) in
            
            //最後に画像を削除
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
            
        }
    }
}









