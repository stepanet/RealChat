//
//  Extensions.swift
//  RealChat
//
//  Created by Jack Sp@rroW on 14/08/2018.
//  Copyright © 2018 Jack Sp@rroW. All rights reserved.
//
import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }

    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!) { (data, response, error) in
        if error != nil {
                    print(error!)
                    return
        }

        DispatchQueue.main.async {
            if let downloadedImage = UIImage(data: data!) {
                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                self.image = UIImage(data: data!)
            }
        
    }
    }.resume()

    }
    
}
