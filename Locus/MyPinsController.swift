//
//  MyPinsController.swift
//  Locus
//
//  Created by Nabil K on 2017-03-01.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class MyPinsController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseService.getPinsForUser(id: ThisUser.instance!.id, local: true) { [weak self] pins in
            
            self?.pins = pins
            self?.collectionView.reloadData()
            
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension MyPinsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FollowersPinCell
        
        let thisPin = pins[indexPath.row]
        
        
        if let imageSource = thisPin.imageRef{
            cell.pinImageView.sd_setImage(with: imageSource)
        }
        
        return cell
    }
    
    
    
    
    
    
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show details of this pin
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

