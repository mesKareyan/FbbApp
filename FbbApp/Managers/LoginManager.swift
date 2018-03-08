//
//  LoginManager.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/7/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth

enum LoginResult {
    case success(UserInfo)
    case failure(Error)
}
typealias LoginCompletion = (LoginResult) -> ()

enum RequestResult<T> {
    case success(data: T)
    case failure(error: Error)
}
typealias RequestCompletion<T> = (RequestResult<T>) -> ()

enum InternalError: Error {
    case unknown
    case facebookLoginError
    case facebookError
    case firebaseLoginError
}

class LoginManager {
    
    private init() {}
    static private(set) var currentUser: UserInfo! = nil
    
    static func loginWith(fbLoginResult: FBSDKLoginManagerLoginResult,
                             completion: @escaping LoginCompletion) {
        DispatchQueue.main.async {
            logInToFirebase(loginCompletion: { result in
                completion(result)
            })
        }
    }
    
    static func logOut(completion: @escaping LoginCompletion) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            DispatchQueue.main.async {
                completion(.success(currentUser))
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                completion(.failure(signOutError))
            }
        }
    }
    
    private static func logInToFirebase(loginCompletion:@escaping LoginCompletion) {
        let credential = FacebookAuthProvider.credential(withAccessToken:
            FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                loginCompletion(.failure(error))
                return
            }
            guard let firebaseUser = user else {
                loginCompletion(.failure(InternalError.firebaseLoginError))
                return
            }
            //get user data from Facebook
            getFacebookInfoFor(firebaseUser: firebaseUser, completion: loginCompletion)
        }
    }
    
    static func getFacebookInfoFor(firebaseUser: FirebaseAuth.User,
                                     completion:@escaping LoginCompletion) {
        getUserFacebookInfo() { result in
            switch result {
            case .failure(error: let error):
                completion(.failure(error))
            case .success(data: let fbUserInfo):
                FirebaseDBManager.updateUserInfo(firebaseInfo: firebaseUser,facebookInfo: fbUserInfo) { userInfo in
                        currentUser = userInfo
                        completion(.success(userInfo))
                }
            }
        }
    }
    
    private static func getUserFacebookInfo(completion: @escaping RequestCompletion<UserInfo>) {
        
        let parameters = ["fields": "email,name,picture.type(large)"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me",
                                             parameters: parameters)!
        
        graphRequest.start(completionHandler: { (connection, result, error) in
            if let error = error  {
                completion(.failure(error: error))
            } else {
                guard
                    let resultDict = result as? NSDictionary,
                    let name  = resultDict["name"] as? String,
                    let picInfo = resultDict["picture"] as? NSDictionary,
                    let picData = picInfo["data"] as? NSDictionary,
                    let photoUrl = picData["url"] as? String
                    else {
                        completion(.failure(error: InternalError.facebookError))
                        return
                }
                let user = UserInfo(name: name, photoURL: photoUrl, id: "")
                completion(.success(data: user))
            }
        })
    }
    
}
