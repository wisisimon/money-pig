//
//  UITextField+Placeholder.swift
//  money-pig
//
//  Created by Mac on 2018/5/5.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        
        set {
            if let placeholder = self.placeholder {
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: newValue!])
            }
        }
    }
}
