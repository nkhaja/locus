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
    var selectedUserId: String?
    
    // The id of the user who's map is being overlayed with our own
    var overlayMap: String?



    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: better way to do this?
        
        
        let nib = UINib(nibName: "FollowerPreviewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "FollowerPreviewCell")
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "followersPins"{
            if let pinsofFollowingController = segue.destination as? PinsOfFollowingController{
                pinsofFollowingController.id = selectedUserId
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return "Active Maps"
        case 1:
            return "Followers"
        default:
            return ""
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            if overlayMap == nil{
                return 0
            }
            else {return 1}
            
        case 1:
            return filteredFollowing.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        // if the textfield has been made blank, populate table with all names

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerPreviewCell") as! FollowerPreviewCell
        
 
            
        if searchField.text == nil || searchField.text == "" {
            filteredFollowing = following
            
        }
        
        // inner argument returns an id, that hashes to a name from the outer dict
        cell.nameLabel.text = filteredFollowing[indexPath.row].name
        cell.indexPath = indexPath
        cell.delegate = self
        
        
        if indexPath.section == 0 {
            
            // TODO: change the image here when this occurs instead of the title
            cell.addMapButton.setTitle("Remove Map", for: .normal)
        }
        
        
        return cell

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idForRow = filteredFollowing[indexPath.row].id
        

    }
    
}


extension FollowingUsersController: PreviewCellDelegate{
    
    func addMap(indexPath: IndexPath, isActive: Bool) {
        
        let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
        let mapVc = nav.viewControllers[0] as! MapViewController

        
        if indexPath.section == 0 {
            
            
            mapVc.removeFollowerMap(id: overlayMap!)
            self.overlayMap = nil

            
        }
        
        else {
            
            // don't add the same map twice
            guard overlayMap != following[indexPath.row].id
                else{return}
           
            self.overlayMap = following[indexPath.row].id
            mapVc.overlayFollowerMap(id: overlayMap!)
            
        }
        
        
        tableView.reloadData()
        
    }
    
    func seeDetails(indexPath: IndexPath) {
       
        selectedUserId = following[indexPath.row].id
        performSegue(withIdentifier: "followersPins", sender: self)

        
        //function to set active Map
    }
    
    
}

