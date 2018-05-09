//
//  ViewController.swift
//  money-pig
//
//  Created by Mac on 2018/5/5.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 註冊Event
    @IBAction func login(_ sender: UIButton) {
        // Validate the input
        guard let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "" else {
                
                let alertController = UIAlertController(title: "登入錯誤", message: "email和密碼欄位不得為空。", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Perform login by calling Firebase APIs
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
            
            if let error = error {
                let alertController = UIAlertController(title: "登入錯誤", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Email verification
            guard let currentUser = user?.user, currentUser.isEmailVerified else {
                let alertController = UIAlertController(title: "登入錯誤", message: "您沒有驗證郵件，以致於無法登入成功，請確定是否已經驗證後，再進行登入。如果沒有收到驗證信，請再重發驗證信已予驗證，謝謝。", preferredStyle: .alert)

                let okayAction = UIAlertAction(title: "重發email", style: .default, handler: { (action) in
                    user?.user.sendEmailVerification(completion: nil)
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                alertController.addAction(cancelAction)

                self.present(alertController, animated: true, completion: nil)

                return
            }
            
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Present the main view
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func unwindToLoginView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // fb登入
    @IBAction func fbLogin(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self)
        { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // 呼叫 Firebase APIs 來執行登入
            Auth.auth().signIn(with: credential, completion:
            { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "fb登入錯誤", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // 呈現主視圖
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    // google登入
    @IBAction func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "google登入錯誤", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Present the main view
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    // google disconnect
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("google disconnect with \(error.localizedDescription)")
        
    }
}
