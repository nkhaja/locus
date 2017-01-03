//
//  LocusMapView.swift
//  Locus
//
//  Created by Nabil K on 2016-12-27.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

class LocusMapView: MKMapView {
    var selectedMark:MKPlacemark?
    
    func setup(){
        self.showsBuildings = true
        self.mapType = .standard
        
        let mapCamera = MKMapCamera()
        
        mapCamera.pitch = 45
        mapCamera.altitude = 500
        mapCamera.heading = 45
        
        self.camera = mapCamera
        self.delegate?.mapView!(self, regionDidChangeAnimated: true)
    }


    

}
