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
    var thisUser: User?
    var locationManager =  CLLocationManager()
    var currentPosition: CLLocation?
    var resultSearchController: UISearchController?
    var thisUserID: String = FIRAuth.auth()!.currentUser!.uid
    
    //Pin Variables
    var selectedAnnotation: MKAnnotation?
    var selectedPin: Pin?
    var pins: [Pin] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLocation()
        self.mapView.showsUserLocation = true
        self.mapView.showAnnotations(mapView.annotations, animated: true)
        self.mapView.setup()
        
        
        let thisUserQuery = FIRDatabase.database().reference(withPath: "users/\(thisUserID)")
        let pinQueary = FIRDatabase.database().reference(withPath: "pins").queryOrdered(byChild: "ownderId").queryEqual(toValue: thisUserID)
        thisUserQuery.observe(.value, with: { snapshot in
            self.thisUser = User(snapshot: snapshot)
        })
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "buildPin"{
            if let build = segue.destination as? BuildPinViewController{
                if let title = selectedAnnotation!.title, let subtitle = selectedAnnotation!.subtitle{
                    build.placeName = "\(title ?? ""), \(subtitle ?? "")"
                    build.location = selectedAnnotation?.coordinate
                }
            }
            

        }
        
        else if segue.identifier == "photoLibrary"{
            if let photoLib = segue.destination as? PhotoLibraryController {
                photoLib.delegate = self
            }
        }
    }
    
    func dropPins(){
        for p in self.pins{
            let point = LocusPointAnnotation()
            point.coordinate = p.coordinate
            point.custom = true
            self.mapView.addAnnotation(point)
        }
  
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
    
    func customizePin(){
        
    }
    
    
    
    @IBAction func signOutButton(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImages(_ sender: Any) {
        performSegue(withIdentifier: "photoLibrary", sender: self)

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
        
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if let locusAnnotation = annotation as? LocusPointAnnotation {
            if locusAnnotation.custom{
                
                //Do stuff to customize the view that goes here
                return pinView
            }
        }

        

        
        
        //else build a condition for clustering pins
        pinView?.animatesDrop = true
        return pinView
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        

        let btnHeight = view.frame.height * 0.8
        let smallSquare = CGSize(width: btnHeight, height: btnHeight)
        
        let drive = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        let pinIt = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        
        drive.contentMode = .scaleAspectFit
        pinIt.contentMode = .scaleAspectFit
        
        drive.setBackgroundImage(UIImage(named: "sports-car"), for: .normal)
        pinIt.setBackgroundImage(UIImage(named: "sports-car"), for: .normal)

        
        drive.addTarget(self.mapView, action: #selector(self.mapView.getDirections), for: .touchUpInside)
        pinIt.addTarget(self, action: #selector(self.goBuildPin), for: .touchUpInside)

//        self.performSegue(withIdentifier: "pinIt", sender: self)
        view.leftCalloutAccessoryView = drive
        view.rightCalloutAccessoryView = pinIt
        self.selectedAnnotation = view.annotation
    }
    
    func goBuildPin(){
        performSegue(withIdentifier: "buildPin", sender: self)
    }
    
}


extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        mapView.selectedMark = placemark
        
        let annotation = LocusPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.clearAnnotations()
        mapView.addAnnotation(annotation)
        
        //refactor the lines below into their own function
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: KhajaPhotoLibraryDelegate {
    func getImagesAndMetaData(info: [(image: UIImage, metaData: [String : Any])]) {
        print("cjese")
    }
    
    
    
}
