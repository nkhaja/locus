//
//  IconCollectionCell.swift
//  Locus
//
//  Created by Nabil K on 2017-03-10.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class IconCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView : UIImageView!
    
    
    override func prepareForReuse() {
        
        self.iconImageView.sd_cancelCurrentImageLoad()
        self.iconImageView.image = nil
        
    }
    
    
    
    
}
