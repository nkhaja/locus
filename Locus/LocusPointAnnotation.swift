//
//  CustomAnnotationView.swift
//  Locus
//
//  Created by Nabil K on 2017-01-12.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

class LocusPointAnnotation: MKPointAnnotation {
    var custom: Bool = false
    var pinImage: UIImage?
    var name: String!
    var date: String!
    var pinId: String!
}
