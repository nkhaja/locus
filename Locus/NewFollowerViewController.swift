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
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var filteredUsers = [User]()
    var pendingFollowees = [(id:String, name:String)]()
    
    // array of ids for people we are following
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        FirebaseService.getPendingRequests(user: ThisUser.instance!) { userInfo in
            self.pendingFollowees = userInfo
            print("assigned not issue")
        }
    }
    
    
    @IBAction func editingChanged(_ sender: Any) {
        filteredUsers = []
        
        // make sure text is not nil or blank
        guard let text = searchField.text else {return }
        if text == "" {return}
        
        let query = FirConst.userRef.queryOrdered(byChild: "name").queryStarting(atValue: text)
        query.observe(FIRDataEventType.value, with: { snapshot in
            if snapshot.hasChildren(){
                for snap in snapshot.children{
                    let data = snap as! FIRDataSnapshot
                    let user = User(snapshot: data)
                    
                    // TODO: update when usernames become different from names
                    // Don't include yourself as a result in searchQuery
                    if user.name != ThisUser.instance?.name && user.accountPrivacy != .closed {
                        if user.name.lowercased().hasPrefix(text){
                            self.filteredUsers.append(user)
                        }
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    
    
}


extension NewFollowerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ThisUser.instance!.permissionsWaiting.keys.count
        }
            
        else{
            return filteredUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NewFollowTableViewCell
        
        
        
        if indexPath.section == 0 {
            cell.friendName.text = pendingFollowees[indexPath.row].name
            // image for adding friends
            cell.friendImageView.image = #imageLiteral(resourceName: "add")
            
            return cell
        }
        
        // user at this indexPath
        let rowUser = filteredUsers[indexPath.row]
        
        // logged in user has id of current iteration's user in their list of friends. AKA currentUser is a friend
        if ThisUser.instance?.following[rowUser.id] != nil{
            
            // TODO: replace with Image
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
                let followeeRef = ThisUser.instance!.reference!.child("following").child(selectedUser.id)
                
                // remove this person as someone you are following from db
                followeeRef.removeValue()
            }
            
            // Are we waiting for acceptance from selected User?
            // Cancel the pending request
            if selectedUser.permissionsWaiting[ThisUser.instance!.id] != nil {
                
                // reference to thisUser's request in selected user's data
                let permisisonRef = selectedUser.reference!.child("permissionsWaiting").child(ThisUser.instance!.id)
                
                // cancel request
                permisisonRef.removeValue()
            }
                
                
                
                // Privacy settings are open, we can follow them immediately
            else if selectedUser.accountPrivacy == .open {
                ThisUser.instance?.following[selectedUser.id] = true
                ThisUser.instance?.reference!.child("following").child(selectedUser.id).setValue(true)
                // change image to following icon
            }
                
                
                // We need permission to access their account. Send a request
            else if selectedUser.accountPrivacy == .permission {
                selectedUser.reference?.child("permissionsWaiting").child(ThisUser.instance!.id).setValue(true)
                
                // change image to waiting icon
                // TODO: make sure that updating here is responsive.
            }
            
            
            
            
            
            // Conditions
            // unfollow the person if you're already following
            // you're not following them. Either request to follow or automatically get follow status
        }
            
            // Follow invitations section. Clicking cell accepts invitation to follow.
            
        else {
            
            ThisUser.instance?.reference!.child("followees").child(pendingFollowees[indexPath.row].id).setValue(true)
            
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
    
    
    
    
}

extension NewFollowerViewController: UITextFieldDelegate {
    
}

