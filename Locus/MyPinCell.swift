//
//  MyPinCell.swift
//  Locus
//
//  Created by Nabil K on 2017-03-02.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class MyPinCell: UICollectionViewCell {
    
    var overlayButtonView: OverlayButtonView!
    var indexPath: IndexPath?
    var personal: Bool = true
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        pinImageView.sd_cancelCurrentImageLoad()
        pinImageView.image = nil
    }
    
    
    
}
