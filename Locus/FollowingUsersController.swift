//
//  FriendPinsController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-22.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class FollowingUsersController: UIViewController {
    
    @IBOutlet weak var tableView:  UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    var thisUser:User?
    lazy var filteredFollowing = [Identity]()
    var following = [Identity]()



    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: better way to do this?
        
        FirebaseService.getUsersFollowing(user: ThisUser.instance!, completion: { [weak self] identities in
            
            guard self != nil else{
                return
            }
            
            
            self?.following = identities
            self?.filteredFollowing = self!.following
            self?.tableView.reloadData()
        })

        filteredFollowing = following
    }
    
    
    func setupUsersPins(id: String) {
        FirebaseService.getPinsForUser(id: id, local: false) { pins in
            for p in pins {
                
            }
        }
    }
    
    @IBAction func searchFieldEdited(_ sender: Any) {
        
        // Show all options if filtering on
        guard let text = searchField.text
            else {
                filteredFollowing = following
                return
        }
        
        if text == "" {
            filteredFollowing = following
            return
        }
        
        filteredFollowing = following.filter {
            $0.name.hasPrefix(searchField.text!)
        }
        
        self.tableView.reloadData()
        
    }
    
    
    
    
}

extension FollowingUsersController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFollowing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // if the textfield has been made blank, populate table with all names
        if searchField.text == nil || searchField.text == "" {
            filteredFollowing = following
        
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FollowingUserCell
        
        // inner argument returns an id, that hashes to a name from the outer dict
        cell.nameLabel.text = filteredFollowing[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idForRow = filteredFollowing[indexPath.row].id
        
        
        
        //segue to next controller here
        // pass detailed data about this user to next controller
    }
    
}

