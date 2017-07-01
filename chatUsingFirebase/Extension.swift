//
//  Extension.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/01.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        if let cacheImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cacheImage
            print("cache url\(urlString)")
            return
        }

        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                guard let image = UIImage(data: data!) else { return }
                
                imageCache.setObject(image, forKey: urlString as NSString)
                
                self.image = image
            }
        }).resume()
    }
}
