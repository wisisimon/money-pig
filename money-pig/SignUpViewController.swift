//
//  SignUpViewController.swift
//  money-pig
//
//  Created by Mac on 2018/5/7.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 註冊Event
    @IBAction func registerAccount(_ sender: UIButton) {
        guard let name = nameTextField.text, name != "",
        let email = emailTextField.text, email != "",
        let password = passwordTextField.text, password != ""
        else {
            
            let alertController = UIAlertController(title: "訊息", message: "請確認有輸入暱稱，信箱，密碼等欄位，才可以註冊喔，謝謝。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Register the user account on Firebase
        Auth.auth().createUser(withEmail: email, password: password, completion:
        { (user, error) in
            if let error = error {
                let alertController = UIAlertController(title: "註冊錯誤", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Save the name of the user
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("failed to change the display name:\(error.localizedDescription)")
                    }
                })
            }
            
            // dismiss keyboard
            self.view.endEditing(true)
            
            // send verification email
            user?.sendEmailVerification(completion: nil)
            
            // show verify email
            let alertController = UIAlertController(title: "Email認證", message: "已經寄出認證信，請到信箱點選郵件裡面的link，來完成註冊手續，謝謝。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .cancel, handler: { (action) in
                // dismmiss currentView Controller
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
}

