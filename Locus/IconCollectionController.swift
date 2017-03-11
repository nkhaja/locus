//
//  IconCollectionController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-04.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit



class IconCollectionController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let iconNames = ["bluePushPin", "redGooglePin", "clothesPin", "baguette", "chili", "candy", "doughnut", "egg", "fish", "fruit", "fries", "gingerBreadMan", "glass", "ice-cream", "noodles", "knife", "pint", "glass", "pizza", "sandwich", "shwarma", "steak", "sushi", "turkey", "basketball", "bee", "bicycle", "books", "boxing", "burger", "candy", "coins", "cricket","cup", "deer", "exercise", "flask", "football", "goggles", "golf", "graduate", "hockey", "hummingbird", "lion", "martini", "money", "nemo", "olympics", "owl", "shopping-basket", "shopping-cart", "snorkel", "soccer", "spider-web", "fishing", "rollerSkates", "baseball", "football-helmet", "billiards", "medal", "volleyBall", "karate", "strategy", "swan", "video-camera", "tennis-ball"]
    
    
    var selectedIconName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwind"{
            if let build = segue.destination as? BuildPinViewController, let name = selectedIconName{
                build.iconButton.setImage(UIImage(named:name), for: .normal)
                
                build.pin?.iconName = name
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
        
        
        cell.iconImageView.image = UIImage(named: iconNames[indexPath.row])
        
        return cell
        
        
    }

    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIconName = iconNames[indexPath.row]
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    
    
}
