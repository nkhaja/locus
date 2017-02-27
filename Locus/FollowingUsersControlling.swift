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
    lazy var filteredFollowing = [String]()
    var following = [String]()



    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: better way to do this?
        
        
        for id in ThisUser.instance!.following.keys{
            FirebaseService.getFollowerData(id: id, completion: { name in
                self.following.append(name)
                self.tableView.reloadData()
            })
        }

        
        searchField.delegate = self
        filteredFollowing = following
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        // inner argument returns an id, that hashes to a name from the outer dict
        cell.textLabel?.text = filteredFollowing[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idForRow = filteredFollowing[indexPath.row]
        
        
        
        //segue to next controller here
        
        // pass detailed data about this user to next controller
    }
    
}




extension FollowingUsersController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        filteredFollowing = following.filter{
            $0.contains(string)
        }
        
        self.tableView.reloadData()
        return true
    }
    
    
}
