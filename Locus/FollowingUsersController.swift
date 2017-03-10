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
    var selectedUserId: String?
    
    lazy var refreshControl = UIRefreshControl()
    

    
    // The id of the user who's map is being overlayed with our own
    var overlayMap: String?



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
            self?.tableView.reloadData()
        })
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "followersPins"{
            if let pinsofFollowingController = segue.destination as? PinsOfFollowingController{
                pinsofFollowingController.id = selectedUserId
            }
        }
    }

    
    @IBAction func searchFieldEdited(_ sender: Any) {
        

        
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
        
 
            
        if searchBar.text == nil || searchBar.text == "" {
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
        let storyboard = UIStoryboard(name: "Followers", bundle: nil)
        let pinsOfFollowingVc = storyboard.instantiateViewController(withIdentifier: String(describing: PinsOfFollowingController.self)) as! PinsOfFollowingController
        
        pinsOfFollowingVc.id = selectedUserId
        
        self.present(pinsOfFollowingVc, animated: true, completion: nil)
        
        //function to set active Map
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
        
        filteredFollowing = following.filter {
            $0.name.hasPrefix(searchBar.text!)
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
