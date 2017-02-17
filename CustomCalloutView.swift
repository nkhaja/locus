//
//  CustomCalloutView.swift
//  Locus
//
//  Created by Nabil K on 2017-02-15.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

protocol customCalloutDelegate{
    func viewDetails()
}


class CustomCalloutView: UIView {
    
    var pinId: String!
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
