//
//  FirebaseDatabaseManager.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/8/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseDatabaseManager {
    
    struct ReferencePath {
        private init(){}
        static let users = "users"
    }
    
    //refs
    let dbReference: DatabaseReference
    let usersReference: DatabaseReference
    
    private init() {
        dbReference = Database.database().reference()
        usersReference = Database.database()
            .reference(withPath: ReferencePath.users)
    }
    
    static let shared = FirebaseDatabaseManager()
    
    func updateUserInfo(firebaseInfo: FirebaseAuth.User,
                        facebookInfo: UserInfo,
                        comletion:@escaping (_ updatedInfo: UserInfo) -> ()) {
        user(forID: firebaseInfo.uid) { ref in
            if ref == nil {
                let newUserInfo = UserInfo(name: facebookInfo.name,
                                           photoURL: facebookInfo.photoURL,
                                           id: firebaseInfo.uid)
                self.createUser(with: newUserInfo)
                comletion(newUserInfo)
            } else {
                self.updateUser(with: facebookInfo)
                comletion(facebookInfo)
            }
        }
    }
    
    private func addToDBUser(with userData: UserInfo) {
        let userRef = usersReference.child(userData.id)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
              userRef.child(userData.id).setValue(userData.dictRepresentation)
            }
        }
    }
    
    private func createUser(with userInfo: UserInfo) {
        let userRef = usersReference.child(userInfo.id)
        userRef.setValue(userInfo.dictRepresentation)
    }
    
    private func updateUser(with userInfo: UserInfo) {
        let userRef = usersReference.child(userInfo.id)
        userRef.setValue(userInfo.dictRepresentation)
    }

    private func user(forID userUID: String,
              result: @escaping ((DatabaseReference?) ->())) {
        usersReference.observeSingleEvent(of: .value) { (snap) in
            if snap.hasChild(userUID) {
                //user is exists
                let ref = self.usersReference.child(userUID)
                result(ref)
            } else {
                //new user
                result(nil)
            }
        }
    }

    
}
