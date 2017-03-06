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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var pins = [Pin]()
    var selectedCell: MyPinCell?
    var selectedIndexPath: IndexPath?
    private let refreshControl = UIRefreshControl()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        loadData()
        
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Pins...")
        
        
//        refreshControl.attributedTitle = NSAttributedString(string: "Updating Pins ...", attributes: attributes)


        
        
        

    }
    
    func loadData() {
        
        FirebaseService.getPinsForUser(id: ThisUser.instance!.id, local: true) { [weak self] pins in
            
            self?.pins = pins
            
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()

            self?.collectionView.reloadData()
        }
    }
    
    func setupCollectionView(){
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
    }

    
    func refreshData(sender: Any) {
        
        loadData()
        
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
            self.selectedCell = collectionView.cellForItem(at: indexPath) as! MyPinCell
            
            let nav = self.tabBarController?.viewControllers?[0] as! UINavigationController
            let mapVc = nav.viewControllers[0] as! MapViewController
            self.tabBarController?.selectedIndex = 0
            
            let visitPin = pins[indexPath.row]
            
            
            switch (type) {
                
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
