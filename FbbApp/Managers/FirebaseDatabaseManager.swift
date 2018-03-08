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

struct Refs {
    
    private init() {}
    
    struct Path {
        private init(){}
        static let users = "users"
        static let followings = "followings"
        static let chats = "chats"
        static let chat_participants_list = "chat_participants_list"
    }
    
    //refs
    static let dbReference = Database.database().reference()
    static let usersReference = Database.database().reference(withPath: Path.users)
    static let chatReference = Database.database().reference(withPath: Path.chats)
    static let participantsListReference = Database.database().reference(withPath: Path.chat_participants_list)
    
}

class FirebaseDatabaseManager {
    

    private init() {
    }
    
    
    
    static func updateUserInfo(firebaseInfo: FirebaseAuth.User,
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
    
    static func getUserslist(usersList: @escaping ([UserInfo]) ->()) {
        Refs.usersReference.observeSingleEvent(of: .value) { (snap) in
            var users: [UserInfo] = []
            snap.children.forEach { snapItem in
                let snp = snapItem as! DataSnapshot
                let user =  UserInfo(snapshot: snp)!
                if user.id != LoginManager.currentUser.id {
                    users.append(user)
                }
            }
            DispatchQueue.main.async {
                usersList(users)
            }
        }
    }
    
    private static func createUser(with userInfo: UserInfo) {
        guard !userInfo.id.isEmpty else {
            assert(false, "userInfo is incorrect: \(userInfo)")
        }
        let userRef = Refs.usersReference.child(userInfo.id)
        userRef.setValue(userInfo.dictRepresentation)
        userRef.child("chats").setValue("")
    }
        
    private static func updateUser(with userInfo: UserInfo) {
        guard !userInfo.id.isEmpty else {
            assert(false, "userInfo is incorrect: \(userInfo)")
        }
        let userRef = Refs.usersReference.child(userInfo.id)
        userRef.updateChildValues(["name": userInfo.name, "photo" : userInfo.photoURL])
        updateFollowings(userInfo: userInfo)
    }

    private static func user(forID userUID: String,
              result: @escaping ((DatabaseReference?) ->())) {
        Refs.usersReference.observeSingleEvent(of: .value) { (snap) in
            if snap.hasChild(userUID) {
                //user is exists
                let ref = Refs.usersReference.child(userUID)
                result(ref)
            } else {
                //new user
                result(nil)
            }
        }
    }
    
    static func updateFollowings(userInfo: UserInfo) {
        let userRef = Refs.usersReference.child(userInfo.id)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let newUserInfo = UserInfo(snapshot: snapshot) {
                userInfo.updateFallowings(ids: newUserInfo.followingIds)
            }
        }
    }
    
    static func user(user: UserInfo, followUser: UserInfo) {
        let userRef = Refs.usersReference.child(user.id)
        let followers = userRef.child(Refs.Path.followings)
        followers.child(followUser.id).setValue(followUser.name)
        self.updateFollowings(userInfo: user)
    }
    
    static func user(user: UserInfo, unfollowUser: UserInfo) {
        let userRef = Refs.usersReference.child(user.id)
        let followers = userRef.child(Refs.Path.followings)
        let unfollowRef = followers.child(unfollowUser.id)
        unfollowRef.removeValue()
        self.updateFollowings(userInfo: user)
    }
    
}
