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
        static let followings = "followings"
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
            let newUserInfo = UserInfo(name: facebookInfo.name,
                                       photoURL: facebookInfo.photoURL,
                                       id: firebaseInfo.uid)
            if ref == nil {
                self.createUser(with: newUserInfo)
                comletion(newUserInfo)
            } else {
                self.updateUser(with: newUserInfo)
                comletion(newUserInfo)
            }
        }
    }
    
    func getUserslist(usersList: @escaping ([UserInfo]) ->()) {
        usersReference.observeSingleEvent(of: .value) { (snap) in
            let users = snap.children.map {
                UserInfo(snapshot: $0 as! DataSnapshot)!
            }
            DispatchQueue.main.async {
                usersList(users)
            }
        }
    }
    
    private func createUser(with userInfo: UserInfo) {
        guard !userInfo.id.isEmpty else {
            assert(false, "userInfo is incorrect: \(userInfo)")
        }
        let userRef = usersReference.child(userInfo.id)
        userRef.setValue(userInfo.dictRepresentation)
    }
        
    private func updateUser(with userInfo: UserInfo) {
        guard !userInfo.id.isEmpty else {
            assert(false, "userInfo is incorrect: \(userInfo)")
        }
        let userRef = usersReference.child(userInfo.id)
        userRef.updateChildValues(["name": userInfo.name, "photo" : userInfo.photoURL])
        updateFollowings(userInfo: userInfo)
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
    
    func updateFollowings(userInfo: UserInfo) {
        let userRef = usersReference.child(userInfo.id)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let newUserInfo = UserInfo(snapshot: snapshot) {
                userInfo.updateFallowings(ids: newUserInfo.followingIds)
            }
        }
    }
    
    func user(user: UserInfo, followUser: UserInfo) {
        let userRef = usersReference.child(user.id)
        let followers = userRef.child(ReferencePath.followings)
        followers.child(followUser.id).setValue(followUser.name)
        self.updateFollowings(userInfo: user)
    }
    
    func user(user: UserInfo, unfollowUser: UserInfo) {
        let userRef = usersReference.child(user.id)
        let followers = userRef.child(ReferencePath.followings)
        let unfollowRef = followers.child(unfollowUser.id)
        unfollowRef.removeValue()
        self.updateFollowings(userInfo: user)
    }
    
}
