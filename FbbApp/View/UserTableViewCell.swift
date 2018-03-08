//
//  UserTableViewCell.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/8/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        userImageView.layer.masksToBounds = true
        backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.3)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(for userInfo: UserInfo) {
        //TODO: make calls async, enable caching
        let imageData = try! Data(contentsOf: URL(string: userInfo.photoURL)!)
        userImageView.image = UIImage(data: imageData)
        userNameLabel.text = userInfo.name
    }

}
