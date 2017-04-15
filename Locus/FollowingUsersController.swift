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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var thisUser:User?
    lazy var filteredFollowing = [Identity]()
    
    var following = [Identity]()
    var selectedUserId: Identity?
    
    
    lazy var refreshControl = UIRefreshControl()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    

    
    // The id of the user who's map is being overlayed with our own
    var overlayMap: Identity?



    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: better way to do this?
        
        
        let nib = UINib(nibName: "FollowerPreviewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "FollowerPreviewCell")
        
        loadData()
        setupCollectionView()
        setupRefreshing()
    
    }
    
    func setupCollectionView(){
        
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
        
        FirebaseService.getUsersFollowing(user: ThisUser.instance!, completion: { [weak self] identities in
            
            guard self != nil else{
                return
            }
            
            
            self?.following = identities
            self?.filteredFollowing = self!.following
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()
            self?.tableView.reloadData()
        })
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "followersPins"{
            if let pinsofFollowingController = segue.destination as? PinsOfFollowingController{
                pinsofFollowingController.id = selectedUserId?.id
            }
        }
    }

    
    
    
    
    
}

extension FollowingUsersController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return "Viewing"
        case 1:
            return "You are Following"
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
        
        // make sure these are set to default state in case changed at any point
        
        cell.addMapButton.isEnabled = true
        cell.unfollowButton.isEnabled = true
        cell.unfollowButton.layer.opacity = 1
        cell.addMapButton.backgroundColor = UIColor(red: 57/255, green: 175/255, blue: 254/255, alpha: 1.0)
 
        // No search query, show all options
        if searchBar.text == nil || searchBar.text == "" {
            filteredFollowing = following
            
        }
        
        // disable addMap button if this map is currently active
        if overlayMap?.id == filteredFollowing[indexPath.row].id && indexPath.section == 1{
            cell.addMapButton.isEnabled = false
            cell.addMapButton.backgroundColor = UIColor.gray
        }
        
        
        // inner argument returns an id, that hashes to a name from the outer dict
        cell.nameLabel.text = filteredFollowing[indexPath.row].name
        cell.indexPath = indexPath
        cell.delegate = self
        cell.unfollowButton.backgroundColor = UIColor.red
        
        
        if indexPath.section == 0 {
            
            cell.nameLabel.text = overlayMap!.name
            cell.addMapButton.setImage(#imageLiteral(resourceName: "back_white"), for: .normal)
            cell.unfollowButton.isEnabled = false
            cell.unfollowButton.layer.opacity = 0
        }
        
        
        return cell

        
    }
    
}


extension FollowingUsersController: PreviewCellDelegate{
    
    func addMap(indexPath: IndexPath, isActive: Bool) {
        
        let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
        let mapVc = nav.viewControllers[0] as! MapViewController

        
        if indexPath.section == 0 {
            
            
            mapVc.removeFollowerMap(id: overlayMap!.id)
            self.overlayMap = nil

            
        }
        
        else {
            
            // don't add the same map twice
            guard overlayMap?.id != following[indexPath.row].id
                else{return}
           
            self.overlayMap = following[indexPath.row]
            mapVc.overlayFollowerMap(id: overlayMap!.id)
            
        }
        
        
        tableView.reloadData()
        
    }
    
    func seeDetails(indexPath: IndexPath) {
       
        selectedUserId = following[indexPath.row]
        
        if filteredFollowing.count > 0{
            selectedUserId = filteredFollowing[indexPath.row]
        }
        
        let storyboard = UIStoryboard(name: "Followers", bundle: nil)
        let pinsOfFollowingVc = storyboard.instantiateViewController(withIdentifier: String(describing: PinsOfFollowingController.self)) as! PinsOfFollowingController
        
        pinsOfFollowingVc.id = selectedUserId?.id
        
        self.present(pinsOfFollowingVc, animated: true, completion: nil)
        
        //function to set active Map
    }
    
    
    func unfollowUser(indexPath: IndexPath) {
        
        
        let unfollowUserId = following[indexPath.row].id
        let unfollowName = following[indexPath.row].name
        
        let alert = UIAlertController(title: "Unfollowing this user", message: "Are you sure you want to unfollow \(unfollowName)? ", preferredStyle: .alert)
        
        
        let confirmAction = UIAlertAction(title: "Unfollow", style: .destructive) { alert in
            
            FirebaseService.unfollowUser(followingUserId: ThisUser.instance!.id, followedUserId: unfollowUserId) { [weak self] Void in
                
                self?.loadData()
                
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(confirmAction)
        
        self.present(alert, animated: true, completion: nil)
        

        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && overlayMap == nil {
            return 0
        }
        
        return 40
        
        
        
    }
    
}

extension FollowingUsersController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Show all options if filtering on
        guard let text = searchBar.text
            else {
                filteredFollowing = following
                return
        }
        
        if text == "" {
            filteredFollowing = following
            return
        }
        
        filteredFollowing = []
        for follower in following{
            if follower.name.lowercased().hasPrefix(searchBar.text!.lowercased()){
                filteredFollowing.append(follower)
            }
        }
        
        
        self.tableView.reloadData()

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
