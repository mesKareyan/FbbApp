//
//  ChatViewController.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/8/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    var user: UserInfo!
    private(set) var chatRef: DatabaseReference!
    private(set) var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForFirebase()
    }
    
    // MARK: UITextViewDelegate methods
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
    }
    // MARK: UI Configuration
    private func configureUI(){
        self.title = self.user.name
        self.senderDisplayName = self.user.name
        view.backgroundColor = UIColor.clear
        collectionView.backgroundColor = .clear
        collectionView.backgroundColor = UIColor.groupTableViewBackground
        collectionView.typingIndicatorMessageBubbleColor = UIColor.white
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
        showTypingIndicator = true
        self.inputToolbar.tintColor = UIColor.jsq_messageBubbleBlue()
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "coloredSent").withRenderingMode(.alwaysTemplate), for: .normal)
        inputToolbar.contentView.rightBarButtonItem = button
        inputToolbar.contentView.leftBarButtonItem = nil
        inputToolbar.contentView.textView.layer.cornerRadius = 10
        UserAvatar.photoURL = user.photoURL
    }
    
    private func configureForFirebase() {
        self.senderId = LoginManager.currentUser.id
        ChatManager.makeChatConnection(fromUser: LoginManager.currentUser, toUser: self.user) { (ref) in
            self.chatRef = ref
            self.observeMessages()
        }
    }
    
    //MARK: - JSQMessages UI
    private lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let button = bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        return button!
    }()
    
    private lazy var incomingBubbleImageView: JSQMessagesBubbleImage = {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let bubble =  bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.white)
        return bubble!
    }()
    
}

//MARK: Collection View Delegate
extension ChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView.textColor = .white
        } else {
            cell.textView.textColor = .darkText
        }
        cell.addShadowToImageViews()
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.bounds.height / 2;
        cell.avatarImageView.layer.masksToBounds = true
        cell.clipsToBounds = false
        return cell
    }
}

//MARK: JSQMessages
extension ChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        return message.senderId == senderId ? outgoingBubbleImageView : incomingBubbleImageView
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
            let message = messages[indexPath.item]
            return (message.senderId == senderId) ? CurrentUserAvatar() : UserAvatar()
    }
    
    //MARK: Actions
    override func didPressSend(_ button: UIButton!,
                               withMessageText text: String!,
                               senderId: String!,
                               senderDisplayName: String!,
                               date: Date!) {
        let message = Message(senderID: senderId, text: text, date: date)
        ChatManager.send(message: message, toChat: chatRef)
        finishSendingMessage()
    }
    
    private func observeMessages() {
        let messageQuery = chatRef.queryLimited(toLast:25).queryOrdered(byChild: "date")
        let _ = messageQuery.observe(.childAdded, with: { (snapshot) -> () in
            if let message = Message(snapshot: snapshot) {
                self.addMessage(message)
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    private func addMessage(_ message: Message) {
        if let message = JSQMessage(senderId: message.senderID, displayName: "", text: message.text) {
            messages.append(message)
        }
    }

}

private class UserAvatar: NSObject, JSQMessageAvatarImageDataSource {
    
    static var photoURL: String = ""
    static let userImage: UIImage? = {
        guard
            let url = URL(string: photoURL),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else { return nil }
        return image
    }()
    
    func avatarImage() -> UIImage! {
        return UserAvatar.userImage
    }
    
    func avatarHighlightedImage() -> UIImage! {
        return nil
    }
    
    func avatarPlaceholderImage() -> UIImage! {
        return nil
    }
    
}

private class CurrentUserAvatar: NSObject, JSQMessageAvatarImageDataSource {
    
    static var photoURL: String = ""
    static let userImage: UIImage? = {
        guard
            let url = URL(string: LoginManager.currentUser.photoURL),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else { return nil }
        return image
    }()
    
    func avatarImage() -> UIImage! {
        return CurrentUserAvatar.userImage
    }
    
    func avatarHighlightedImage() -> UIImage! {
        return nil
    }
    
    func avatarPlaceholderImage() -> UIImage! {
        return nil
    }
    
}

//Add shadow for message bubbles
extension UIView {
    func addShadowToImageViews(){
        for view in subviews {
            if let imageView = view as? UIImageView {
                imageView.layer.shadowColor = UIColor.lightGray.cgColor
                imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
                imageView.layer.shadowOpacity = 1
                imageView.layer.shadowRadius = 1.0
                imageView.clipsToBounds = false
                continue
            }
            view.addShadowToImageViews()
        }
    }
}

