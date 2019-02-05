//
//  User.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 13/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImage: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImage = dictionary["profileImage"] as? String
    }
}
