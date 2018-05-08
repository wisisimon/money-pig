//
//  ProfileViewController.swift
//  money-pig
//
//  Created by Mac on 2018/5/7.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ProfileViewController : UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = Auth.auth().currentUser {
            nameLabel.text = currentUser.displayName
            emailLabel.text = currentUser.email
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func popView(_ sender: Any) {
        if let navcontroller = self.navigationController {
            navcontroller.popViewController(animated: true)
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        
        do {
            // 登出先讓google登出
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                
                switch userInfo.providerID {
                case "google.com":
                    GIDSignIn.sharedInstance().signOut()
                default:
                    break
                }
            }
            // 之後firebase登出
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            let alertController = UIAlertController(title: "登出錯誤", message: signOutError.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Back To Login View
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}
