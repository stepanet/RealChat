//
//  Message.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 19/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit
import FirebaseAuth

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    var imageWidth: Float?
    var imageHeigth: Float?
    
    init(dictionary: [String: AnyObject]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.toId = dictionary["toId"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? Float
        self.imageHeigth = dictionary["imageHeigth"] as? Float
    }
    
    func chatPartnerId() -> String? {
        
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId

    }
}
