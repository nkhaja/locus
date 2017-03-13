//
//  MyPinsController.swift
//  Locus
//
//  Created by Nabil K on 2017-03-01.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit


// TODO: Optimize space to searchResults not stored twice

class MyPinsController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pins = [Pin]()
    var selectedCell: MyPinCell?
    var selectedIndexPath: IndexPath?
    
    
    private let refreshControl = UIRefreshControl()
    
    // Searching Vars
    
    var filteredPins = [Pin]()
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupRefreshing()
        loadData()

    }
    

    // Mark: Setup
    func setupCollectionView(){
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
    }
    
    
    func setupRefreshing(){
        
        
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Pins...")
        
    }
    
    
    // Mark: Get Data
    
    func loadData() {
        
        FirebaseService.getPinsForUser(id: ThisUser.instance!.id, local: true) { [weak self] pins in
            
            self?.pins = pins
            
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()
            
            self?.collectionView.reloadData()
        }
    }

    
    func refreshData(sender: Any) {
        
        loadData()
        
    }
    
   

}

// Mark: CollectionView Functions
extension MyPinsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if filteredPins.count > 0 {
            return filteredPins.count
        }
        
        return pins.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyPinCell
        
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
        
        if let selectedIndexPath = self.selectedIndexPath{
            
            let oldCell = collectionView.cellForItem(at: selectedIndexPath) as! MyPinCell
            
            oldCell.overlayButtonView.dismiss()
        }
        
        self.selectedIndexPath = indexPath
        
        let cell = collectionView.cellForItem(at: indexPath) as! MyPinCell
        
        // Set overlayView; assign delegate, put on cells view, animate
        cell.overlayButtonView = OverlayButtonView(frame: cell.bounds)
        cell.overlayButtonView.indexPath = indexPath
        cell.overlayButtonView.delegate = self
        cell.addSubview(cell.overlayButtonView)
        
        cell.overlayButtonView.setColors(north: .green, south: .red, east: .purple, west: .blue)
        cell.overlayButtonView.animateButtons()
        
        
        
    }
    
    
    
    // Mark: Collectionview Layout
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


// Mark: OverlayButtonView Delegate Functions
extension MyPinsController: OverlayButtonViewDelegate {
    
    func overlayButtonTriggered(type: OverlayButtonType, indexPath: IndexPath?) {
        
        if let indexPath = indexPath {
            self.selectedCell = collectionView.cellForItem(at: indexPath) as! MyPinCell
            
            let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
            let mapVc = nav.viewControllers[0] as! MapViewController
            
            let isfiltering = filteredPins.count > 0
            
            var visitPin: Pin
            
            
            if filteredPins.count == 0{
                visitPin = pins[indexPath.row]
            }
                
            else{
                
                visitPin = filteredPins[indexPath.row]
            }
            
            
            switch (type) {
                
            case .east:
                visitPin.image = selectedCell?.pinImageView.image
                mapVc.selectedPin = visitPin
                mapVc.performSegue(withIdentifier: "buildPin", sender: mapVc)
                
                
            case .west:
                
                // TODO: horrible, fix it
                
                self.tabBarController?.selectedIndex = 0
                mapVc.panTo(coordinate: visitPin.coordinate, mapView: mapVc.mapView)
            
            
            case .north:
                print("north")
                
                let storyboard = UIStoryboard(name: "EditPin", bundle: Bundle.main)
                
                let pinDetailController = storyboard.instantiateViewController(withIdentifier: "PinDetailController") as! PinDetailController
                
                
                pinDetailController.pin = visitPin
                
                self.present(pinDetailController, animated: true, completion: nil)
                
               
            
            case .south:
                
                let deletePinAlert = UIAlertController(title: "Delete Pin", message: "Are you sure you want to delete this pin?", preferredStyle: .alert)
                
                
                // Mark: Delete this Pin
                let deleteAction = UIAlertAction(title: "DELETE", style: .destructive, handler: { [weak self] action in
                    
                    
                    
                    visitPin.delete(){
                        
                        if isfiltering {
                            let index = self?.pins.index(of: visitPin)!
                            self?.pins.remove(at: index!)
                            self?.filteredPins.remove(at: indexPath.row)
                        }
                            
                        else {
                            
                            self?.pins.remove(at: indexPath.row)
                            
                        }
                        
                        mapVc.mapView.removePinWith(coordinate: visitPin.coordinate)
                        self?.loadData()
                    }
 
                })
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                deletePinAlert.addAction(deleteAction)
                deletePinAlert.addAction(cancelAction)
                
                
                self.present(deletePinAlert, animated: true, completion: nil)
                

                }
            }
    }
}

// Mark: Searching

extension MyPinsController {

    
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
    

}



// Mark: Searchbar Delegate

extension MyPinsController: UISearchBarDelegate{
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.doSearchFor(text: searchText)
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
