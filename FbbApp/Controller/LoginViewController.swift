//
//  ViewController.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/7/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        createFBLoginButton()
    }
    
    func createFBLoginButton() {
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        self.contentView.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton
            .centerXAnchor
            .constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        loginButton
            .centerYAnchor
            .constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }
    
    func showError(_ error: Error) {
        let alert =
            UIAlertController(title: "Error",
                              message: error.localizedDescription,
                              preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openUsersList(forUser user: UserInfo) {
        
    }
    
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!,
                     didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        guard error == nil else {
            self.showError(error!)
            return
        }
        guard !result.isCancelled else {
            return
        }
        //login to firebase
        LoginManager.loginWith(fbLoginResult: result) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.openUsersList(forUser: user)
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }
    
}





