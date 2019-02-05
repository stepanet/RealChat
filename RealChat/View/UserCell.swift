//
//  UserCell.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 20/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import Firebase


class UserCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {

            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text
            if let second = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: second)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    

    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "profileImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 12)
        return label
    }()
    
    private func setupNameAndProfileImage() {
        
        if let id  = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImage"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                    
                }
            }, withCancel: nil)
        }
        
    }

    override func layoutSubviews() {
         super.layoutSubviews()
        textLabel?.textColor = UIColor(named: "mainTheme") //.red
        detailTextLabel?.textColor = UIColor(named: "mainTheme") //UIColor(r: 0, g: 137, b: 249)
        textLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 16)
        detailTextLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 16)
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! + 2, width: (textLabel?.frame.width)! + 10, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)! + 10, height: (detailTextLabel?.frame.height)!)
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)
        addSubview(timeLabel)

        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
