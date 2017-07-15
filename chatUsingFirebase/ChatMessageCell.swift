//
//  ChatMessageCell.swift
//  chatUsingFirebase
//
//  Created by park kyung suk on 2017/07/15.
//  Copyright © 2017年 park kyung suk. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var textView: UITextView = {
    
        let tv = UITextView()
        tv.text = "Sample Text!"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        //textView constraint
        textView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
