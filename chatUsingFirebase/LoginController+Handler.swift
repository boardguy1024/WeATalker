//
//  LoginController+Handler.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/25.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

extension LoginViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //登録ボタン押下時呼び出される
    func handleRegister() {
        
        if nameTextfield.text == nil || nameTextfield.text == "" {
            showAlertView(title: "名前を入力してください", message: "")
            return
        }
        
        if !checkValidInputForLoginOrRegister() {
            return
        }
        
        guard let email = emailTextfield.text , let password = passwordTextfield.text , let name = nameTextfield.text else {
            
            print("Form is not valid")
            return
        }
        
        SVProgressHUD.show()
        //ユーザー登録が完了するとUIDが取得できる
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            SVProgressHUD.dismiss()
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            //Successfully Authenticated user
            
            // uuidを生成してくれるこれでイメージ名を設定しストレージに保存
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image ,
                let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                storageRef.put(uploadData, metadata: nil, completion: { (metaData, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metaData?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name , "email": email , "profileImageUrl": profileImageUrl]
                        
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                    }
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        
        let ref = FIRDatabase.database().reference()
        
        let userRef = ref.child("users").child(uid)
        
        
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
           // self.messageController?.navigationItem.title = values["name"] as? String
            
            let user = User()
            user.setValuesForKeys(values)
            self.messageController?.setupNavBarWithUser(user: user)
            
            print("Successfully saved into Firebase db")
            
            //dbに成功すれば本画面を閉じる
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        //editモードを表示する
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    //MARK:- ImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- AlertController
    func showAlertView(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- 入力バリデーション
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func checkValidInputForLoginOrRegister() -> Bool {
        
        //入力バリデーションチェック
        if emailTextfield.text == nil || emailTextfield.text == "" {
            showAlertView(title: "emailを入力してください", message: "")
            return false
        } else {
            if !isValidEmailAddress(emailAddressString: emailTextfield.text!) {
                showAlertView(title: "正しいemailを入力してください", message: "")
                return false
            }
        }
        
        if passwordTextfield.text == nil || passwordTextfield.text == "" {
            showAlertView(title: "パスワードを入力してください", message: "")
            return false
        } else {
            if !(passwordTextfield.text!.characters.count > 7) {
                showAlertView(title: "パスワードは８桁以上を入力してください", message: "")
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}











