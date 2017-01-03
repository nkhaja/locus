//
//  FirstViewController.swift
//  Locus
//
//  Created by Nabil K on 2016-12-17.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class MapViewController: UIViewController {
    
    
    // Location Variables
    
    @IBOutlet weak var mapView: LocusMapView!
    var locationManager =  CLLocationManager()
    var currentPosition: CLLocation?
    var resultSearchController: UISearchController?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLocation()
        self.mapView.showsUserLocation = true
        self.mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    
    
    
    
    
    //Setup Functions
    
    func setupLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
//        locationManager.startUpdatingLocation()
        
        // SEARCH BAR
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        //searchBar.backgroundColor = MapHelper.hexStringToUIColor("#00a774")
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        mapView.delegate = self
    }
    
    
    
    @IBAction func signOutButton(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }
}


extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            currentPosition = location
            self.mapView.setRegion(region, animated: true)
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}





extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        //else build a condition for clustering pins
        
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")! as MKAnnotationView
        
        return pinView
    }
    
}


extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        mapView.selectedMark = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
    }
    
}
