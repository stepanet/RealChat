//
//  NewMessageController.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 12/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase



class NewMessageController: UITableViewController {
    
    let cellId = "Cell"
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "mainTheme") //UIColor.red
        
        fetchUser()

    }
    
    func fetchUser(){
   
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {

                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            }
        }
        
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell //(withIdentifier: cellId)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        
        if let profileImageUrl = user.profileImage {
           cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
        let user = self.users[indexPath.row]
        self.messagesController?.showChatControllerForUser(user)
        }
    }
}
