//
//  PinsOfFollowingController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-26.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseStorageUI

class PinsOfFollowingController: UIViewController {
    
    var pins = [Pin]()
    var id: String!
    var selectedIndexPath: IndexPath?
    var selectedCell: FollowersPinCell?
    
    var filteredPins = [Pin]()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    private let refreshControl = UIRefreshControl()

    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupRefreshing()
        loadData()
    }
    
    func setupCollectionView(){
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
    }
    
    
    func setupRefreshing(){
        
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Pins...")
        
    }
    
    
    // Mark: Get Data
    
    func loadData() {
        
        FirebaseService.getPinsForUser(id: id, local: false) { [weak self] pins in
            
            self?.pins = pins
            
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()
            
            self?.collectionView.reloadData()
        }
    }
    
    
    
    
//    @IBAction func backButton(_ sender: Any) {
//        
//        self.dismiss(animated: true, completion: nil)
//    }
    
}


extension PinsOfFollowingController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FollowersPinCell
        cell.indexPath = indexPath
        
        var thisPin: Pin
        
        if filteredPins.count == 0{
            thisPin = pins[indexPath.row]
        }
            
        else{
            
            thisPin = filteredPins[indexPath.row]
        }
        
        cell.indexPath = indexPath
        
        
        if let imageSource = thisPin.imageRef{
            cell.pinImageView.sd_setImage(with: imageSource)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedIndexPath = self.selectedIndexPath {
            
            let oldCell = collectionView.cellForItem(at: selectedIndexPath) as! FollowersPinCell
            
            oldCell.overlayButtonView.dismiss()
        }
        
        self.selectedIndexPath = indexPath
        
        let cell = collectionView.cellForItem(at: indexPath) as! FollowersPinCell
        
        // Set overlayView; assign delegate, put on cells view, animate
        cell.overlayButtonView = OverlayButtonView(frame: cell.bounds)
        cell.overlayButtonView.indexPath = indexPath
        cell.overlayButtonView.delegate = self
        cell.addSubview(cell.overlayButtonView)
        cell.overlayButtonView.animateButtons()
        cell.overlayButtonView.northButton.isHidden = true
        cell.overlayButtonView.setImages(north: nil, south: #imageLiteral(resourceName: "flag-white"), east: #imageLiteral(resourceName: "details-white"), west: #imageLiteral(resourceName: "map"))
        
        cell.overlayButtonView.setColors(north: .white, south: .red, east: .purple, west: .blue)
        
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
}


extension PinsOfFollowingController: OverlayButtonViewDelegate {
    
    func overlayButtonTriggered(type: OverlayButtonType, indexPath: IndexPath?) {
        
        if let indexPath = indexPath {
            self.selectedCell = collectionView.cellForItem(at: indexPath) as! FollowersPinCell
            

            var visitPin: Pin
            
            if filteredPins.count == 0{
                visitPin = pins[indexPath.row]
            }
                
            else{
                
                visitPin = filteredPins[indexPath.row]
            }
            
            
            switch (type) {
            
            // Add this pin to your map
                
            case .east:
                
               
                let pinDetailVc = Helper.instantiateController(storyboardName: "EditPin", controllerName: String(describing: PinDetailController.self), bundle: nil) as! PinDetailController
            
                
                self.present(pinDetailVc, animated: true, completion: nil)
                

                
                
            case .west:
                
                // TODO: horrible, fix it

                
                let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
                let mapVc = nav.viewControllers[0] as! MapViewController
                self.tabBarController?.selectedIndex = 0
                
                mapVc.panTo(coordinate: visitPin.coordinate, mapView: mapVc.mapView)
                mapVc.dropPins(pins: [visitPin])
                
                
            case .north:
                return

                
            
            case .south:
                visitPin.delete(){
                    
                    let flagAlert = self.createFlagAlertFor(pin: visitPin)
                    self.present(flagAlert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    
    func createFlagAlertFor(pin:Pin) -> UIAlertController {
        let alert = UIAlertController(title: "Flag this Pin", message: "Are you sure you want to flag this pin for inappropriate content?", preferredStyle: .alert)
        
        let flagAction = UIAlertAction(title: "Flag", style: .default, handler: { action in
            
            
            
            
            let flag = Flag(fromUser: ThisUser.instance!.id, toUser: pin.ownerId, pinId
                : pin.id!)
            FirebaseService.saveFlag(flag: flag)
            
        })
        
        alert.addAction(flagAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
        
    }
}


extension PinsOfFollowingController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) { 
            
            // do animations to expand size past back button here
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5) {
            
            
           // do animations to shrink textfield to accommodate back button
            
        }
        
        
        return true
 
    }
    

}

extension PinsOfFollowingController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        doSearchFor(text: searchText)
    }
    
    
    func doSearchFor(text:String?){
        
        guard let text = text else {return }
        if text == "" {
            
            self.filteredPins.removeAll()
            collectionView.reloadData()
            return
            
        }
        
        for p in pins{
            
            if p.title.contains(text) || p.placeName.contains(text) || p.date.toString().contains(text){
                
                if !filteredPins.contains(p){
                    filteredPins.append(p)
                }
            }
        }
        
        self.loadData()
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





