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
    
}


class FollowerPreviewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addMapButton: UIButton!
    
    weak var delegate: PreviewCellDelegate?
    var indexPath: IndexPath!
    var isActive = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

}
