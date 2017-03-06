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

protocol LocusMapDelegate {
    
    func zoomTo(coordinate: CLLocationCoordinate2D)
    
}


class MapViewController: UIViewController {
    
    // Location Variables
    @IBOutlet weak var mapView: LocusMapView!
//    var thisUser: User?
    var locationManager =  CLLocationManager()
    var currentPosition: CLLocation?
    var resultSearchController: UISearchController?
    var thisUserID: String = FIRAuth.auth()!.currentUser!.uid
    
    //Pin Variables
    var selectedAnnotation: MKAnnotation?
    var selectedPin: Pin?


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLocation()
        self.mapView.showsUserLocation = true
        self.mapView.showAnnotations(mapView.annotations, animated: true)
        self.mapView.setup()
        
        
        FirebaseService.updateUser(id: thisUserID) {
            
            ThisUser.instance?.getAllPins {
                self.dropPins(pins: Array(ThisUser.instance!.pins.values))
            }
        }
        
        // Refactor this
        let pinQuery = FIRDatabase.database().reference(withPath: "pins").queryOrdered(byChild: "ownderId").queryEqual(toValue: thisUserID)

    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "buildPin"{
            if let build = segue.destination as? BuildPinViewController{
                
                if let title = selectedAnnotation?.title, let subtitle = selectedAnnotation? .subtitle{
                    build.placeName = "\(title ?? ""), \(subtitle ?? "")"
                    build.location = selectedAnnotation?.coordinate
                }
            
                
                if let editPin = selectedPin {
                    
                    build.pin = selectedPin
                    
                }
            
            }
            

            
            
        }
        
        else if segue.identifier == "photoLibrary"{
            if let photoLib = segue.destination as? PhotoLibraryController {
                photoLib.delegate = self
            }
        }
    }
    
    func dropPins(pins:[Pin]){
        
        // TODO: setup system where only pins not on map are added to it; instead of clearing and putting on.
        for p in pins{
            let point = LocusPointAnnotation()
            point.coordinate = p.coordinate
            point.custom = true
            point.date = p.date.toString()
            point.name = "Hard-Coded"
            point.pinImage = p.image
            point.pinId = p.id
            self.mapView.addAnnotation(point)
        }
    }
    
    
    
    
    // MARK: Setup Functions
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
    
    
    
    func panTo(coordinate: CLLocationCoordinate2D, mapView: MKMapView){
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func signOutButton(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImages(_ sender: Any) {
        performSegue(withIdentifier: "photoLibrary", sender: self)
    }
    
    @IBAction func unwindFromPinBuilder(segue: UIStoryboardSegue){

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
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        
        if let locusAnnotation = annotation as? LocusPointAnnotation {
            if locusAnnotation.custom {
                
                
                //Do stuff to customize the view
                if pinView == nil {
                    
                    let customAnnotationView = CustomAnnotationView(annotation: locusAnnotation, reuseIdentifier: "pin")
                    
                    customAnnotationView.frame.size = CGSize(width: 30, height: 30)
                    customAnnotationView.image = #imageLiteral(resourceName: "redGooglePin")
                    customAnnotationView.canShowCallout = false
                    customAnnotationView.pinId = locusAnnotation.pinId
                
                    return customAnnotationView
                    
                }
                
                else{
                    
                    return pinView
                }
            }
            
            else{
                
                if pinView == nil{
                    let standardPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                    standardPin.canShowCallout = true
                    standardPin.animatesDrop = true
                    return standardPin
                }
                
                else{
                    return pinView
                }
                
            }
        }

        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let customAnnotation = view.annotation as? LocusPointAnnotation else {return}
        
        if customAnnotation.custom {
            
            self.mapView.selectedMark = MKPlacemark(coordinate: customAnnotation.coordinate)

            let xib = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
            let customView = xib?[0] as! CustomCalloutView
            
            // Set Fields for customView
            customView.dateLabel.text = customAnnotation.date
            customView.nameLabel.text = customAnnotation.name
            customView.pinImageView.image = customAnnotation.pinImage
            customView.pinId = customAnnotation.pinId
            
            let thisPin = ThisUser.instance?.pins[customAnnotation.pinId]
            
            // load image for selected pin
            customView.pinImageView.sd_setImage(with: thisPin!.imageRef!, maxImageSize: 1 * 1024 * 1024, placeholderImage: UIImage(), completion: nil)

            
            customView.frame.size = CGSize(width: 150, height: 150)
            customView.center = CGPoint(x: view.bounds.size.width / 2, y: -customView.bounds.size.height*0.52)
            
            view.addSubview(customView)
            self.panTo(coordinate: thisPin!.coordinate, mapView: self.mapView)

        }
        
        else {
            
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
            
            view.leftCalloutAccessoryView = drive
            view.rightCalloutAccessoryView = pinIt
            self.selectedAnnotation = view.annotation
            view.canShowCallout = true
        
            
        }

    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let deselectedAnnotation = view as? CustomAnnotationView else {return}
        
        for sub in view.subviews {
            if let selectedView = sub as? CustomCalloutView{
                if selectedView.pinId == deselectedAnnotation.pinId{
                    selectedView.removeFromSuperview()
                }
            }
        }
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

extension MapViewController: Mappable{
    
    func getSelectedGpsPhotos(gpsPhotos: [GpsPhoto]) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        var newPins = [Pin]()
        for photo in gpsPhotos{
            
            let newPin = Pin(ownerId: uid!, coordinate: photo.location, image: photo.image)
            newPin.save(newAlbum: nil)
            newPins.append(newPin)
            
        }
        
        self.dropPins(pins: newPins)
    }
}


extension MapViewController: CustomCalloutDelegate {
    
    func viewDetails() {
        print("completed!")
    }
    
    
    
}
