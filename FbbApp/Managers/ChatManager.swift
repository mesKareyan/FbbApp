//
//  ChatManager.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/8/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ChatManager {
    
    private init() {}
    
    static func createNewChat(from fromUser: UserInfo, to toUser: UserInfo) -> DatabaseReference {
        //1.create new chat node
        let newChatRef = Refs.chatReference.childByAutoId()
        //2. create new chat participants list node
        let newParticipantListRef = Refs.participantsListReference.childByAutoId()
        newParticipantListRef.child("chatID").setValue(newChatRef.key)
        newParticipantListRef.child("users").child(fromUser.id).setValue(fromUser.name)
        newParticipantListRef.child("users").child(toUser.id).setValue(toUser.name)
        newChatRef.child("plistID").setValue(newParticipantListRef.key)
        //3. add chat info to end users nodes
        fromUser.firebaseDBRef.child("chats").child(toUser.id).setValue(newParticipantListRef.key)
        toUser.firebaseDBRef.child("chats").child(fromUser.id).setValue(newParticipantListRef.key)
        return newChatRef
    }
    
    static func send(message: Message, toChat chat: DatabaseReference) {
        let newMessage = chat.childByAutoId()
        newMessage.setValue(message.dictRepresentation)
    }
    
    static func makeChatConnection(fromUser: UserInfo, toUser: UserInfo,
                                   comletion: @escaping (DatabaseReference) ->()) {
        fromUser.firebaseDBRef.child("chats").child(toUser.id).observe(.value) { (snap) in
            if snap.exists() {
                let chatPlistID  = snap.value as! String
                Refs.participantsListReference.child(chatPlistID).child("chatID").observe(.value, with: { (snap) in
                    let chatID = snap.value as! String
                    let chatRef = Refs.chatReference.child(chatID).child("messages")
                    comletion(chatRef)
                })
            } else {
                let chatRef = self.createNewChat(from: fromUser, to: toUser)
                comletion(chatRef)
            }
        }
    }
    
}
