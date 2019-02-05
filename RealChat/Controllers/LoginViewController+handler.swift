//
//  LoginViewController+handler.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 13/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func handleRegister(){
        //print("selector handleLogin")
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("error")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard (authResult?.user) != nil else {
                print(error!)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            
            //поместим выбранную картинку в бд
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        
            //let uploadData = self.profileImageView.image!.pngData()!
            if let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.1) {
        
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata: StorageMetadata?, error) in
                if error != nil {
                    print(error!)
                    return
                }
            
                storageRef.downloadURL(completion: { (profileImageUrl, error) in
                    if error != nil {
                        return
                    }
                    
                    
                    if let profileImageUrl = profileImageUrl?.absoluteString {
                        
                        //наш массив имя и емайл и путь к картинке
                        let values = ["name": name, "email": email, "profileImage": profileImageUrl] as [String : Any]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            })
            }
            self.dismiss(animated: true, completion: nil)
        }        
    }
    
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
       
        //определим путь к базеданных
        let ref = Database.database().reference(fromURL: "https://realchat-b3a41.firebaseio.com/")
        //определим в какую таблицу и какие значения будем записывать
        let userReference = ref.child("users").child(uid)

        //обновим значения
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }

            let user = User(dictionary: values)
            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    
    //выбор картинки в профайл
    @objc func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectImageFromPicker:UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectImageFromPicker = originalImage
        }
        if let selectedImage = selectImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

