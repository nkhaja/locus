//
//  FriendsViewController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-18.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import Firebase


// TODO: Updating the tableView immediately. Don't rely on FB to make the changes.

class NewFollowerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var filteredUsers = [User]()
    lazy var pendingFollowers = [Identity]()
    lazy var refreshControl = UIRefreshControl()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    var headerHeight: CGFloat = 40
    
    // array of ids for people we are following
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupRefreshing()
        setupTableviewView()
        
        searchBar.layer.borderWidth = 0
        
        
        loadData()
        

    }
    
    func setupTableviewView(){
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
    }
    
    
    func setupRefreshing(){
        
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Pins...")
        
    }
    
    
    
    
    func loadData(){
        
        let permissionsWaitingIds = Array(ThisUser.instance!.permissionsWaiting.keys)
        
        FirebaseService.getPendingRequests(ids: permissionsWaitingIds) { [weak self] userInfo in
            

            self?.pendingFollowers = userInfo
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()
            self?.tableView.reloadData()
            
        }
        
    }
}


extension NewFollowerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pendingFollowers.count
        }
            
        else{
            return filteredUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NewFollowTableViewCell
        
        
        
        if indexPath.section == 0 {
            cell.friendName.text = pendingFollowers[indexPath.row].name
            // image for adding friends
            cell.friendImageView.image = #imageLiteral(resourceName: "add")
            
            return cell
        }
        
        // user at this indexPath
        let rowUser = filteredUsers[indexPath.row]
        
        // logged in user has id of current iteration's user in their list of friends. AKA currentUser is a friend
        if ThisUser.instance?.following[rowUser.id] != nil{
            
            // put image to indicate user is being followed already
            cell.friendImageView.image = #imageLiteral(resourceName: "checkmark")
        }
            
            
            // Put image of pending request
        else if rowUser.permissionsWaiting[ThisUser.instance!.id] != nil {
            cell.friendImageView.image = #imageLiteral(resourceName: "sent")
        }
            
        else {
            cell.friendImageView.image = #imageLiteral(resourceName: "add")
        }
        
        cell.friendName.text = rowUser.name
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let selectedUser = filteredUsers[indexPath.row]
            
            
            // get db reference to selected user
            if ThisUser.instance?.following[selectedUser.id] != nil{
                let followeeRef = ThisUser.instance!.reference!.child(FirConst.following).child(selectedUser.id)
                
                // remove this person as someone you are following from db
                followeeRef.removeValue()
            }
            
            // Are we waiting for acceptance from selected User?
            // Cancel the pending request
            if selectedUser.permissionsWaiting[ThisUser.instance!.id] != nil {
                
                // reference to thisUser's request in selected user's data
                let permisisonRef = selectedUser.reference!.child(FirConst.permissionsWaiting).child(ThisUser.instance!.id)
                
                // cancel request
                permisisonRef.removeValue()
            }
                
                
                
                // Privacy settings are open, we can follow them immediately
            else if selectedUser.accountPrivacy == .open {
                ThisUser.instance?.following[selectedUser.id] = true
                ThisUser.instance?.reference!.child(FirConst.following).child(selectedUser.id).setValue(true)
                // change image to following icon
            }
                
                
                // We need permission to access their account. Send a request
            else if selectedUser.accountPrivacy == .permission {
                selectedUser.reference?.child(FirConst.permissionsWaiting).child(ThisUser.instance!.id).setValue(true)
                
                // change image to waiting icon
                // TODO: make sure that updating here is responsive.
            }
            
            
            
            
            
            // Conditions
            // unfollow the person if you're already following
            // you're not following them. Either request to follow or automatically get follow status
        }
            
            // Follow invitations section. Clicking cell accepts invitation to follow.
            
        else {
            
            let newFollowerId = pendingFollowers[indexPath.row].id
            FirConst.userRef.child(newFollowerId).child(FirConst.following).child(ThisUser.instance!.id).setValue(true)
            ThisUser.instance!.reference!.child(FirConst.permissionsWaiting).child(newFollowerId).removeValue()
            
            pendingFollowers.remove(at: indexPath.row)
            tableView.reloadData()
            
            
            // The above operationjo triggers a listener to handle remaining logic
            // TODO: Add feature where users can ignore requests
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Pending Requests"
        case 1:
            return "Search Results"
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && pendingFollowers.count == 0 {
            return 0
        }
        
        return headerHeight
        
        
        
    }
    
    
    
    
}

extension NewFollowerViewController: UITextFieldDelegate {
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension NewFollowerViewController: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredUsers = []
        
        // make sure text is not nil or blank
        guard let text = searchBar.text?.lowercased() else {return }
        if text == "" {
            
            self.filteredUsers.removeAll()
            tableView.reloadData()
            return
            
        }
        
        let query = FirConst.userRef.queryOrdered(byChild: FirConst.name).queryStarting(atValue: text)
        
        query.observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
            if snapshot.hasChildren(){
                for snap in snapshot.children{
                    let data = snap as! FIRDataSnapshot
                    let user = User(snapshot: data)
                    
                    // TODO: update when usernames become different from names
                    // Don't include yourself as a result in searchQuery
                    if user.name != ThisUser.instance?.name && user.accountPrivacy != .closed {
                        if user.name.lowercased().hasPrefix(text) {
                            self.filteredUsers.append(user)
                        }
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    
    }
    
    func dismissKeyboard(){
        
        searchBar.resignFirstResponder()
        
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    
    
}

