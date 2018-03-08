//
//  UserInfo.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/7/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import Foundation

struct UserInfo {
    
    let name: String
    let photoURL: String
    let id: String
    
    var dictRepresentation: [String:Any] {
        var dict = [String: String]()
        dict["name"] = name
        dict["photo"] = photoURL;
        return dict
    }
}
