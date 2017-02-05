//
//  IconCollectionController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-04.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let iconNames = ["bluePushPin", "yellowPushPin", "redGooglePin", "clothesPin", "baguette", "chili", "candy", "doughnut", "egg", "fish", "fruit", "fries", "gingerBreadMan", "glass", "ice-cream", "noodles", "knife", "pint", "glass", "pizza", "sandwich", "shwarma", "steak", "sushi", "turkey", "basketball", "bee", "bicycle", "books", "boxing", "burger", "candy", "coins", "cricket","cup", "deer", "exercise", "flask", "football", "goggles", "golf", "graduate", "hockey", "hummingbird", "lion", "martini", "money", "nemo", "olympics", "owl", "shopping-basket", "shopping-cart", "snorkel", "soccer", "spider-web", "fishing", "rollerSkates", "baseball", "football-helmet", "billiards", "medal", "volleyBall", "karate", "strategy", "swan", "video-camera", "tennis-ball"]

class IconCollectionController: UICollectionViewController {
    
    var selectedIconName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return iconNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let rect = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        let iconImageView = UIImageView(frame: rect)
        iconImageView.center = cell.center
        iconImageView.image = UIImage(named: iconNames[indexPath.row])
        cell.addSubview(iconImageView)
//        cell.backgroundColor = UIColor.black
        
        
    
        // Configure the cell
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwind"{
            if let build = segue.destination as? BuildPinViewController, let name = selectedIconName{
                build.iconButton.setImage(UIImage(named:name), for: .normal)
                
                build.pin?.iconName = name
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIconName = iconNames[indexPath.row]
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cellImageView = cell.subviews[0]
        cellImageView.removeFromSuperview()
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
