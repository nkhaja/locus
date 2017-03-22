//
//  LocusMapView.swift
//  Locus
//
//  Created by Nabil K on 2016-12-27.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit
import MapKit

class LocusMapView: MKMapView, Clearable {
    var selectedMark:MKPlacemark?
    
    func setup(){
        self.showsBuildings = true
        self.mapType = .satelliteFlyover
        
        let mapCamera = MKMapCamera()
        
        mapCamera.pitch = 45
        mapCamera.altitude = 500
        mapCamera.heading = 45
        
        
        self.camera = mapCamera
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        
        self.isUserInteractionEnabled = true
        
    }
    
    func getDirections(){
        let mapItem = MKMapItem(placemark: selectedMark!)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    
    
    func handleTap(sender:UILongPressGestureRecognizer){
        print("long pressing map")
        let point = sender.location(in: self)
        let coordinate = self.convert(point, toCoordinateFrom: self)
        let annotation = LocusPointAnnotation()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        annotation.coordinate = coordinate
        
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil{
                print("Reverse geocoder failed with error" + error!.localizedDescription)
            }
            
            if placemarks!.count > 0{
                let placemark = placemarks![0]
                annotation.title = placemark.name //+ ", " + pm.subThoroughfare!
                if let city = placemark.locality, let state = placemark.administrativeArea{
                    annotation.subtitle = "\(city) \(state)"
                }
            }
            
            else{
                annotation.title = "Unregistered Location"
            }
            

            self.clearAnnotations()
            self.addAnnotation(annotation)
            self.selectAnnotation(annotation, animated: true)
        }

        
    }
    
    func removePinWith(coordinate: CLLocationCoordinate2D){
        
        
        // TODO: more performant version of this code
        for a in self.annotations{
            if a.coordinate == coordinate {
                self.removeAnnotation(a)
            }
        }
        
    }
}

extension CLLocationCoordinate2D : Equatable{
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        
        if lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude{
            return true
        }
        
        return false
    }
    
}
