//
//  MyPinsController.swift
//  Locus
//
//  Created by Nabil K on 2017-03-01.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

class MyPinsController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var pins = [Pin]()
    var selectedCell: FollowersPinCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseService.getPinsForUser(id: ThisUser.instance!.id, local: true) { [weak self] pins in
            
            self?.pins = pins
            self?.collectionView.reloadData()
            
        }
    }
}


extension MyPinsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyPinCell
        cell.indexPath = indexPath
        
        let thisPin = pins[indexPath.row]
        
        cell.indexPath = indexPath
        
        
        if let imageSource = thisPin.imageRef{
            cell.pinImageView.sd_setImage(with: imageSource)
        }
        
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! MyPinCell
        
        // Set overlayView; assign delegate, put on cells view, animate
        cell.overlayButtonView = OverlayButtonView(frame: cell.frame)
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


extension MyPinsController: OverlayButtonViewDelegate {
    
    func overlayButtonTriggered(type: OverlayButtonType, indexPath: IndexPath?) {
        
        if let indexPath = indexPath {
           self.selectedCell = collectionView.cellForItem(at: indexPath) as? FollowersPinCell

            
            switch (type) {
            
            case .east:
                print("east tapped")
               

            case .west:
                
                // TODO: horrible, fix it
                
                let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
                let mapVc = nav.viewControllers[0] as! MapViewController
                self.tabBarController?.selectedIndex = 0
                mapVc.dropPinZoomIn(placemark: MKPlacemark(coordinate: pins[indexPath.row].coordinate))
            }
        
        }

    }
    
    
    
}
