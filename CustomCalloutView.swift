//
//  CustomCalloutView.swift
//  Locus
//
//  Created by Nabil K on 2017-02-15.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

protocol CustomCalloutDelegate: class{
    func viewDetails()
}


class CustomCalloutView: UIView {
    
    var pinId: String!
    weak var delegate: CustomCalloutDelegate?
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(triggerDelegate))
        self.addGestureRecognizer(tap)
    }
    
    func triggerDelegate(){
        if let delegate = delegate{
            delegate.viewDetails()
        }
        
    }
    

}
