//
//  UserInfo.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/7/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserInfo {
    
    let name: String
    let photoURL: String
    let id: String
    var followingIds: [String] = [];
    
    var dictRepresentation: [String:Any] {
        var dict = [String: String]()
        dict["name"] = name
        dict["photo"] = photoURL;
        return dict
    }
    
    init(name: String, photoURL: String, id: String) {
        self.name = name
        self.photoURL = photoURL
        self.id = id
    }
        
    init?(snapshot: DataSnapshot) {
        guard let data = snapshot.value as? NSDictionary,
            let name = data["name"] as? String,
            let photoURL = data["photo"] as? String
            else { return nil }
        self.name = name
        self.photoURL = photoURL
        self.id = snapshot.key
        if let followings = data["followings"] as? NSDictionary {
            self.followingIds = followings.allKeys as! [String]
        }
    }
    
    func follow(user: UserInfo) {
        FirebaseDatabaseManager.shared.user(user: self, followUser: user)
    }
    
    func unfollow(user: UserInfo) {
        FirebaseDatabaseManager.shared.user(user: self, unfollowUser: user)
    }
    
    func updateFallowings(ids: [String]) {
        self.followingIds = ids
    }
    
}



