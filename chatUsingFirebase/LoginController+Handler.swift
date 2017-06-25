//
//  LoginController+Handler.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/25.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //登録ボタン押下時呼び出される
    func handleRegister() {
        
        guard let email = emailTextfield.text , let password = passwordTextfield.text , let name = nameTextfield.text else {
            
            print("Form is not valid")
            return
        }
        
        //ユーザー登録が完了するとUIDが取得できる
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            //Successfully Authenticated user
            
            // uuidを生成してくれるこれでイメージ名を設定しストレージに保存
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                
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
        
        let ref = FIRDatabase.database().reference(fromURL: "https://chatfirebase-5b8fc.firebaseio.com/")
        
        let userRef = ref.child("users").child(uid)
        
        
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
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
}
