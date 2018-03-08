//
//  UsersTableViewController.swift
//  
//
//  Created by Mesrop Kareyan on 3/8/18.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    var users: [UserInfo]!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        LoginManager.logOut { (result) in
            switch result {
            case .failure(let error):
                break
            case .success(let user):
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loadUsers() {
        FirebaseDatabaseManager.shared.getUserslist { (users) in
            self.users = users
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return users?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",
                                                       for: indexPath) as? UserTableViewCell
            else {
            return UITableViewCell()
        }
        let userInfo = self.users[indexPath.section]
        cell.configure(for: userInfo)
        let isUserInCurrentUserFollowings =  LoginManager.currentUser.followingIds.contains(userInfo.id)
        cell.accessoryType = isUserInCurrentUserFollowings ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 4
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = self.users[indexPath.section];
        let followAction = UITableViewRowAction(style: .normal, title: "follow") { (rowAction, indexPath) in
            LoginManager.currentUser.follow(user: user)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        followAction.backgroundColor = .blue
        
        let unfollowAction = UITableViewRowAction(style: .normal, title: "unfollow") { (rowAction, indexPath) in
            LoginManager.currentUser.unfollow(user: user)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        unfollowAction.backgroundColor = .red
        let isUserInCurrentUserFollowings =  LoginManager.currentUser.followingIds.contains(user.id)
        
        return  isUserInCurrentUserFollowings ? [unfollowAction] : [followAction]
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }


}
