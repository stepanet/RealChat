//
//  ViewController.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 11/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(handleLogOut))
        
        let image = UIImage(named: "new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "mainTheme") //UIColor.red
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "mainTheme") // UIColor.red
        self.navigationItem.backBarButtonItem?.tintColor = UIColor(named: "mainTheme")
        //color back button navigation
        self.navigationController?.navigationBar.tintColor = UIColor(named: "mainTheme")
        
        
        chekIfUserLogedIn()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        observeUserMessages()
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
        let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
                
            }, withCancel: nil)
  
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    private func fetchMessageWithMessageId(_ messageId: String) {
       
        let messafeReference = Database.database().reference().child("messages").child(messageId)
        messafeReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                
                self.attempReloadOfTable()
                
            }
        }, withCancel: nil)
        
    }
    
    private func attempReloadOfTable(){
    
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style:.subtitle, reuseIdentifier: "cellid")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        //print(message.text, message.toId, message.fromId)
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user)
        }, withCancel: nil)
        
    }
    
    @objc func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func chekIfUserLogedIn() {
        if Auth.auth().currentUser == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()

        }
    }
    
    
    func fetchUserAndSetupNavBarTitle() {
       
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictonary = snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictonary["name"] as? String
                
                let user = User(dictionary: dictonary)
                self.setupNavBarWithUser(user: user)
                
            }
            
        }
    }
    
    func setupNavBarWithUser(user: User){
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//        titleView.backgroundColor = UIColor.red
        
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = UIColor.yellow
//        titleView.addSubview(containerView)
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImage {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        titleView.addSubview(profileImageView)
//
//
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        //profileImageView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textColor = UIColor(named: "mainTheme") //.red
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)

        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

//        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//
        self.navigationItem.titleView = titleView
    }
    

    
    
    @objc func handleLogOut() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = LoginViewController()
        loginVC.messagesController = self
        present(loginVC, animated: true) {
            print("goto loginVC")
        }
    }


}

