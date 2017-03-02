//
//  FollowersPinCell.swift
//  Locus
//
//  Created by Nabil K on 2017-02-26.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class FollowersPinCell: UICollectionViewCell {
    
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        pinImageView.sd_cancelCurrentImageLoad()
        pinImageView.image = nil
    }
    
}
