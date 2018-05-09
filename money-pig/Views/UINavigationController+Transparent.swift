//
//  UINavigationBar+Transparent.swift
//  money-pig
//
//  Created by Mac on 2018/5/5.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the navigation bar transparent
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: UIColor.white]

        
        
//        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationBar.shadowImage = UIImage()
//        self.navigationBar.isTranslucent = true
//        self.navigationBar.tintColor = UIColor.white
//        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 20)!,
//                                                  NSAttributedStringKey.foregroundColor: UIColor.white]
//
    }
}
