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
    
    
    var thisUser: User!
    var filteredUsers = [User]()
    
    // array of ids for people we are following
    var pendingFollowees = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        thisUser.reference!.child("following").observe(.value, with: { snapshot in
            if let followingData = snapshot.value {
                self.thisUser.following = followingData as! [String:Bool]
                self.tableView.reloadData()
            }
        })
        
        thisUser.reference!.child("permissionsWaiting").observe(.value, with: { snapshot in
            if let permissionData = snapshot.value{
                self.thisUser.permissionsWaiting = permissionData as! [String:String]
                self.pendingFollowees = Array(self.thisUser.permissionsWaiting.keys)
                self.tableView.reloadData()
            }
        })
        
        pendingFollowees = Array(self.thisUser.permissionsWaiting.keys)
        
    }
}


extension NewFollowerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return thisUser.permissionsWaiting.keys.count
        }
        
        else{
            return filteredUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NewFollowTableViewCell
        
        if indexPath.section == 0 {
            let rowUserId = pendingFollowees[indexPath.row]
            cell.friendName.text = self.thisUser.permissionsWaiting[rowUserId]
            // image for adding friends
            cell.friendImageView.image = UIImage()
            
            return cell
        }
        
        let rowUser = filteredUsers[indexPath.row]
        
        // logged in user has id of current iteration's user in their list of friends. AKA currentUser is a friend
        if thisUser.following[rowUser.id] != nil{
            
            // TODO: replace with Image
            // put image to indicate user is being followed already
            cell.friendImageView.image = UIImage()
            
            // Put image of pending request
            if rowUser.permissionsWaiting[String(thisUser.id)] != nil {
                cell.friendImageView.image = UIImage()
            }
            
            cell.friendName.text = rowUser.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let selectedUser = filteredUsers[indexPath.row]
            
            
            // get db reference to selected user
            if thisUser.following[selectedUser.id] != nil{
                let followeeRef = thisUser.reference!.child("following").child(selectedUser.id)
                
                // remove this person as someone you are following from db
                followeeRef.removeValue()
            }
            
            // Are we waiting for acceptance from selected User?
            // Cancel the pending request
            if selectedUser.permissionsWaiting[thisUser.id] != nil {
               
                // reference to thisUser's request in selected user's data
                let permisisonRef = selectedUser.reference!.child("permissionsWaiting").child(thisUser.id)
                
                // cancel request
                permisisonRef.removeValue()
            }
                
                
                
            // Privacy settings are open, we can follow them immediately
            else if selectedUser.accountPrivacy == .open {
                self.thisUser.following[selectedUser.id] = true
                self.thisUser.reference!.child("following").child(selectedUser.id).setValue("true")
                // change image to following icon
            }
                
                
            // We need permission to access their account. Send a request
            else if selectedUser.accountPrivacy == .permission {
                selectedUser.reference?.child("permissionsWaiting").child(thisUser.id).setValue("true")
                
                // change image to waiting icon
                // TODO: make sure that updating here is responsive.
            }
            
            
            
            
            
            // Conditions
            // unfollow the person if you're already following
            // you're not following them. Either request to follow or automatically get follow status
        }
        
        // Follow invitations section. Clicking cell accepts invitation to follow.
        
        else {
            
            thisUser.reference!.child("followees").child(pendingFollowees[indexPath.row]).setValue("true")
            
            // The above operation triggers a listener to handle remaining logic
            // TODO: Add feature where users can ignore requests
        }
    }
}

extension NewFollowerViewController: UITextFieldDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let userRef = FIRDatabase.database().reference(withPath: "users")
        
        userRef.observe(FIRDataEventType.value, with: { snapshot in
            if snapshot.hasChildren(){
                for snap in snapshot.children{
                    let data = snap as! FIRDataSnapshot
                    let user = User(snapshot: data)
                    
                    // TODO: update when usernames become different from names
                    // Don't include yourself as a result in searchQuery
                    if user.name != self.thisUser.name && user.accountPrivacy != .closed {
                        if user.name.lowercased().range(of: text.lowercased()) != nil{
                            self.filteredUsers.append(user)
                        }
                    }
                }
            }
        })
        
    return true
    
    }
}
