//
//  FriendsViewController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-18.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import Firebase


class FriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var thisUser: User!
    var filteredUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FriendTableViewCell
        
        let currentUser = filteredUsers[indexPath.row]
        
        
        // logged in user has id of current iteration's user in their list of friends. AKA currentUser is a friend
        if thisUser.friendIds[currentUser.id] != nil{
            
            // TODO: replace with Image
            cell.friendImageView.image = UIImage()
            cell.friendName.text = currentUser.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = filteredUsers[indexPath.row]
        
        
        // Conditions
        // unfollow the person if you're already following
        // you're not following them. Either request to follow or automatically get follow status
        
        
    
        
    }
    
}

extension FriendsViewController: UITextFieldDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let userRef = FIRDatabase.database().reference(withPath: "users")
        
        userRef.observe(FIRDataEventType.value, with: { snapshot in
            if snapshot.hasChildren(){
                for snap in snapshot.children{
                    let data = snap as! FIRDataSnapshot
                    let user = User(snapshot: data)
                    
                    // TODO: update when usernames become different from names
                    // Don't include yourself as a result in searchQuery
                    if user.name != self.thisUser.name {
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
