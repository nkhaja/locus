//
//  CustomAnnotationView.swift
//  Locus
//
//  Created by Nabil K on 2017-02-16.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {
    
    var pinId: String?
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.imageView = UIImageView(frame: self.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
