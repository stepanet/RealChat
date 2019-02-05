//
//  UIColor.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 11/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}