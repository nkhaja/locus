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
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the pins for this user
        
        FirebaseService.getPinsForUser(id: id, local: false, completion: { pins in
            
            self.pins = pins
            self.collectionView.reloadData()
    
        })
        
        

        // Do any additional setup after loading the view.
    }

}


extension PinsOfFollowingController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FollowersPinCell
        cell.indexPath = indexPath
        
        let thisPin = pins[indexPath.row]
        
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
            
            let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
            let mapVc = nav.viewControllers[0] as! MapViewController
            self.tabBarController?.selectedIndex = 0
            
            let visitPin = pins[indexPath.row]
            
            
            switch (type) {
            
            // Add this pin to your map
                
            case .east:
                
                visitPin.image = selectedCell?.pinImageView.image
                mapVc.selectedPin = visitPin
                mapVc.performSegue(withIdentifier: "buildPin", sender: mapVc)
                
                
            case .west:
                
                // TODO: horrible, fix it
                
                mapVc.panTo(coordinate: visitPin.coordinate, mapView: mapVc.mapView)
                
                
            case .north:
                print("north")
                
                let storyboard = UIStoryboard(name: "EditPin", bundle: Bundle.main)
                
                let pinDetailController = storyboard.instantiateViewController(withIdentifier: "PinDetailController") as! PinDetailController
                
                
                pinDetailController.pin = visitPin
                
                self.present(pinDetailController, animated: true, completion: nil)
                
                
                
            case .south:
                visitPin.delete(){
                    
                    //                    self.pins.remove(at: indexPath.row)
                    self.collectionView.reloadData()
                    
                }
            }
            
            
            
        }
        
    }
    
    
}


