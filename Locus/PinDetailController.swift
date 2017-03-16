//
//  PinDetailController.swift
//  Locus
//
//  Created by Nabil K on 2017-03-05.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import SDWebImage

class PinDetailController: UIViewController {
    
    var pin: Pin!
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var pinIconImageView: UIImageView!
    @IBOutlet weak var storyLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        pinImageView.sd_setImage(with: pin.imageRef!)
        
        titleLabel.text = pin .title
        dateLabel.text = pin.date.toString()
        placeNameLabel.text = pin.placeName
        
        storyLabel.text = pin.story
        storyLabel.sizeToFit()
        
        pinIconImageView.image = UIImage(named: pin.iconName)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        self.pinImageView.addGestureRecognizer(tap)
        
        self.pinImageView.isUserInteractionEnabled = true

        

        // Do any additional setup after loading the view.
    }
    
    
    func imageTapped(){
        
        let storyboard = UIStoryboard(name: "PhotoLibrary", bundle: Bundle.main)
        
        let seeImageController = storyboard.instantiateViewController(withIdentifier: "SeeImageController") as! SeeImageController
        
        seeImageController.image = pinImageView.image
        
        self.present(seeImageController, animated: true, completion: nil)
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    


}
