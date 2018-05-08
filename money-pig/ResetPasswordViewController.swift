//
//  ResetPasswordViewController.swift
//  money-pig
//
//  Created by Mac on 2018/5/7.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
  
    @IBOutlet weak var emailTextField: UITextField!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 註冊Event
    @IBAction func resetPassword(_ sender: UIButton) {
        
        // Validate the input
        guard let email = emailTextField.text,
            email != "" else {
                
                let alertController = UIAlertController(title: "輸入錯誤", message: "請提供正確的email。", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Send password reset email
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            
            let title = (error == nil) ? "重設密碼" : "重設密碼錯誤"
            let message = (error == nil) ? "我們已經重新發送一封重設密碼的mail給您，請依照mail指示重設密碼。" : error?.localizedDescription
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "確定", style: .cancel, handler: { (action) in
                
                if error == nil {
                    
                    // Dismiss keyboard
                    self.view.endEditing(true)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            })
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
}

