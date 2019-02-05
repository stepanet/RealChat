//
//  ChatLogController.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 16/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate , ImageZoomable {

    var user: User? {
        didSet{
            navigationItem.title = user?.name

            observeMessages()
        }
    }

    var messages = [Message]()

    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else { return }
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let message = Message(dictionary: dictionary)

                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        //let indexPath = indexPath(item: self.messages.count - 1, section: 0)
                        let ip = IndexPath(item: self.messages.count - 1, section: 0    )
                        self.collectionView?.scrollToItem(at: ip, at: .bottom, animated: true)
                    }
            }, withCancel: nil)
        }, withCancel: nil)

    }

    lazy var inputTextField: UITextField = {
        let textfield = UITextField()
        textfield.delegate = self
        textfield.attributedPlaceholder = NSAttributedString(string: "Введите сообщение...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.textColor = .white

        return textfield
    }()

    let cellId = "cellIdin"

    override func viewDidLoad() {
        super.viewDidLoad()


        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive

        self.inputTextField.delegate = self
        setupKeyboardObservers()

    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)

    }


    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let ip = IndexPath(item: self.messages.count - 1, section: 0    )
            self.collectionView?.scrollToItem(at: ip, at: .top, animated: true)
        }
    }


    lazy var inputConteinerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor(named: "mainTheme")//.red

        //upload pictures button
        let image = UIImage(named: "profileImage")
        let uploadImageView = UIImageView(image: image)
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)

        uploadImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true


        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(UIColor(named: "mainTheme"), for: .normal)
        sendButton.backgroundColor = .white
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)

        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 88).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -10).isActive = true


        containerView.addSubview(inputTextField)

        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor ).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 200)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)

        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true


        return containerView
    }()


    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)

    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        } else  {
            handleImageSelectedForInfo(info)
        }

        dismiss(animated: true, completion: nil)

    }
    
    private func handleVideoSelectedForUrl(_ url: URL) {
        
        let filename = UUID().uuidString + ".mov"
        let ref = Storage.storage().reference().child("message_movies").child(filename)
        
        let uploadTask = ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!)
                return
            }
            
            ref.downloadURL(completion: { (downloadUrl, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let videoUrl = downloadUrl?.absoluteString {
                    if let thumbnailImage = self.thumbnailImageForVideoUrl(url) {
                        self.uploadToFirebaseStorageUsingImage(thumbnailImage, complition: { (imageUrl) in
                            let proprties: [String: Any] = ["videoUrl": videoUrl, "imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeigth": thumbnailImage.size.height]
                            self.sendMessageWithProperties(proprties)
                        })
                    }
                }
                
            })
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completionUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completionUnitCount) + "bytes"
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnailImageForVideoUrl(_ videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1,timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print(error)
        }
        
        
        return nil
    }
    
    private func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectImageFromPicker:UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectImageFromPicker = originalImage
        }
        if let selectedImage = selectImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage) { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            }
        }
        
    }

    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, complition: @escaping(_ imageUrl: String) ->()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message-images").child(imageName)

        if let uploadData = image.jpegData(compressionQuality: 0.2) {

            ref.putData(uploadData, metadata: nil, completion: { (metadata: StorageMetadata?, error) in
                if error != nil {
                    print(error!)
                    return
                }

                ref.downloadURL(completion: { (url, error) in
                    if error != nil {
                        return
                    }

                    if let imageUrl = url?.absoluteString {
                        complition(imageUrl)
                    }

                })
            })
        }    }

    private func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {

        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width , "imageHeigth": image.size.height] as [String: Any]
        sendMessageWithProperties(properties)

    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override var inputAccessoryView: UIView? {

        get {
            return inputConteinerView
        }

    }


    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.delegate = self
      
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        setupCell(cell, message: message)

        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }

        return cell
    }

    private func setupCell(_ cell: ChatMessageCell, message: Message) {

        if let profileImageUrl = self.user?.profileImage {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }

        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.profileImageView.isHidden = true
            cell.bubbleViewRigthAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(named: "mainTheme")//.red
            cell.bubbleViewRigthAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var heigth: CGFloat = 80

        let message = messages[indexPath.row]

        if let text = message.text {
            heigth = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth, let imageHeigth = message.imageHeigth {
            heigth = CGFloat( imageHeigth / imageWidth) * 200
        }

        return CGSize(width: view.frame.width, height: heigth)
    }

    private func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.init(name: "HelveticaNeue-Thin", size: 18)!], context: nil)
    }


    var containerViewBottomAnchor: NSLayoutConstraint?

    @objc func handleSend() {

        let properties = ["text": self.inputTextField.text!]
        sendMessageWithProperties(properties)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        return true
    }

    private func sendMessageWithProperties(_ properties: [String: Any]) {

        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(Date().timeIntervalSince1970)

        var values = ["toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String: Any]
        properties.forEach {values[$0] = $1}

        childRef.updateChildValues(values) { (error, ref) in

            if error != nil {
                print(error!)
                return
            }
            self.inputTextField.text = nil
            self.inputTextField.resignFirstResponder()

            let userMessageRef = Database.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])

            let recieptUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId!)
            recieptUserMessagesRef.updateChildValues([messageId: 1])

        }
    }

    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    func performZoomInForImageView(_ imageView: UIImageView) {
        startingImageView = imageView
        startingImageView?.isHidden = true
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut(_ :))))
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputConteinerView.alpha = 0
                
                let heigth = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: heigth)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }

    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view as? UIImageView {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputConteinerView.alpha = 1
            }) { (complete) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
            
            
        }
    }
    
}
