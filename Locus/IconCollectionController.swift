//
//  IconCollectionController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-04.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit


// had to create this because Xcode bug with unwind segues
protocol IconDelegate : class {
    
    func updateIcon(iconName: String)
    
}

class IconCollectionController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedImage: UIImage?
    weak var iconDelegate : IconDelegate?
    
    let iconNames = ["baguette", "baseball", "basketball", "bee", "bicycle", "billiards", "bluePushPin", "books", "boxing", "burger", "candy", "candy", "chili", "clothesPin", "coins", "cricket", "cup", "deer", "doughnut", "egg", "exercise", "fish", "fishing", "flask", "football", "football-helmet", "fries", "fruit", "gingerBreadMan", "glass", "glass", "goggles", "golf", "graduate", "hockey", "hummingbird", "ice-cream", "karate", "knife", "lion", "martini", "medal", "money", "nemo", "noodles", "olympics", "owl", "pint", "pizza", "pong", "redGooglePin", "rollerSkates", "sandwich", "shopping-basket", "shopping-cart", "shwarma", "snorkel", "soccer", "spider-web", "steak", "strategy", "sushi", "swan", "tennis-ball", "turkey", "video-camera", "volleyBall"]
    
    
    var selectedIconName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwind"{
            if let build = segue.destination as? BuildPinViewController, let name = selectedIconName{
                build.iconButton.setImage(UIImage(named:name), for: .normal)
                
                build.pin?.iconName = name
                build.iconButton.setImage(selectedImage, for: .normal)
            }
        }
    }
}

extension IconCollectionController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "icon", for: indexPath) as! IconCollectionCell
        
        let iconNameForCell = iconNames[indexPath.row] + "@3x.png"
        
        cell.iconImageView.sd_setImage(with: FirConst.iconRef.child(iconNameForCell), placeholderImage: nil) { (image, error, cahce, ref) in
            
            self.selectedImage = image
        }


        
        return cell
        
    }

    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIconName = iconNames[indexPath.row]
        
        iconDelegate?.updateIcon(iconName: selectedIconName!)
        self.dismiss(animated: true, completion: nil)
        
//        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    
    
}
