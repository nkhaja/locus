//
//  FollowerPreviewCell.swift
//  Locus
//
//  Created by Nabil K on 2017-03-06.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

protocol PreviewCellDelegate: class{
    
    func addMap(indexPath: IndexPath, isActive: Bool)
    func seeDetails(indexPath: IndexPath)
    func unfollowUser(indexPath: IndexPath)
    
}


class FollowerPreviewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addMapButton: UIButton!
    @IBOutlet weak var seeDetailsButton: UIButton!
    @IBOutlet weak var unfollowButton: UIButton!
    
    
    weak var delegate: PreviewCellDelegate?
    var indexPath: IndexPath!
    var isActive = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        // make buttons round
        
//        buttons = [addMapButton, seeDetailsButton, unfollowButton]
        
        let inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        self.addMapButton.layer.cornerRadius = addMapButton.frame.width/2
        addMapButton.setImage(#imageLiteral(resourceName: "map"), for: .normal)
        addMapButton.contentMode = .scaleAspectFit
        addMapButton.imageEdgeInsets = inset

       
        self.seeDetailsButton.layer.cornerRadius = seeDetailsButton.frame.width/2
        seeDetailsButton.setImage(#imageLiteral(resourceName: "details-white"), for: .normal)
        seeDetailsButton.contentMode = .scaleAspectFit
        seeDetailsButton.imageEdgeInsets = inset
        

        
        
        // TODO: Fix appearance of shadows here
        self.seeDetailsButton.layer.shadowRadius = 4
        self.seeDetailsButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.seeDetailsButton.layer.shadowColor = UIColor.black.cgColor
        self.seeDetailsButton.layer.shadowOpacity = 0.4


        self.unfollowButton.layer.cornerRadius = unfollowButton.frame.width/2
        unfollowButton.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        unfollowButton.contentMode = .scaleAspectFit
        unfollowButton.imageEdgeInsets = inset

        
    }
    
    
    func createGradiantLayer(){
        
        
        let gradiant = CAGradientLayer()
        
        gradiant.frame = self.bounds
        
        let lightBlue = UIColor(red: 79, green: 202, blue: 255, alpha: 1).cgColor
        
        gradiant.colors = [lightBlue, UIColor.red.cgColor]
        
        self.layer.insertSublayer(gradiant, at: 0)
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addMapButton(_ sender: Any) {
        
        if let delegate = delegate{
            delegate.addMap(indexPath: indexPath, isActive: self.isActive)
        }
        
    }

    
    @IBAction func seeDetailsButton(_ sender: Any) {
        
        if let delegate = delegate{
            delegate.seeDetails(indexPath: indexPath)
        }
        
    }
    
    @IBAction func unfollowButton(_ sender: Any) {
        
        
        if let delegate = delegate{
            
            delegate.unfollowUser(indexPath: indexPath)
        }
        
    }
    


}
