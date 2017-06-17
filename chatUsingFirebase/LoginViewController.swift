//
//  LoginViewController.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/06/18.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    }
    
    //statusBarStyleを明るい方に設定
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    //拡張でrgbInitを簡単に設定できるように新たにInitを追加
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}




