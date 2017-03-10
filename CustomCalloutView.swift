//
//  CustomCalloutView.swift
//  Locus
//
//  Created by Nabil K on 2017-02-15.
//  Copyright © 2017 MakeSchool. All rights reserved.
//


//http://stackoverflow.com/questions/27519517/button-action-in-mkannotation-view-not-working/27519673#27519673
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
        

    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let hitView = super.hitTest(point, with: event)
        if hitView != nil {
            self.superview?.bringSubview(toFront: hitView!)
            print("view hit")
        }
        return hitView
    }
    
    
    override func layoutSubviews() {
    
        // make this image clickable
        
        pinImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(triggerDelegate))
        pinImageView.addGestureRecognizer(tap)
    }

    
    func triggerDelegate(){
        if let delegate = delegate{
            delegate.viewDetails()
        }
    }
    
    @IBAction func calloutTapped(_ sender: Any) {
        
        print("tapped")
        
    }
    
    

}
