//
//  Message.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/9/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    let senderID: String
    let text: String
    let date: Date
    
    var dictRepresentation: [String: String] {
        return ["senderID": senderID,
                "text" : text,
                "date" : String(date.timeIntervalSince1970)]
    }
    
    init(senderID: String, text: String, date: Date) {
        self.senderID = senderID
        self.text = text
        self.date = date
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let data = snapshot.value as? NSDictionary,
            let senderID = data["senderID"] as? String,
            let text = data["text"] as? String,
            let date = data["date"] as? String,
            let timeInterval = TimeInterval(date)
            else { return nil }
        self.senderID = senderID
        self.text = text
        self.date = Date(timeIntervalSince1970: timeInterval)
    }
    
}
