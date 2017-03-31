//
//  FirstViewController.swift
//  Locus
//
//  Created by Nabil K on 2016-12-17.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

// https://robots.thoughtbot.com/how-to-handle-large-amounts-of-data-on-maps

import UIKit
import Firebase
import GoogleSignIn
import MapKit
import SDWebImage

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol LocusMapDelegate {
    
    func zoomTo(coordinate: CLLocationCoordinate2D)
    
}


class MapViewController: UIViewController {
    
    // Location Variables
    @IBOutlet weak var mapView: LocusMapView!
    @IBOutlet weak var pinDetailButton: UIButton!
    @IBOutlet weak var editPinButton: UIButton!
    
    

    var locationManager =  CLLocationManager()
    var currentPosition: CLLocation?
    var resultSearchController: UISearchController?
    var thisUserID: String = FIRAuth.auth()!.currentUser!.uid
    var tempAnnotation: MKAnnotation?
    
    //Pin Variables
    var selectedAnnotation: MKAnnotation?
    var selectedPin: Pin?
    
    var customView: CustomCalloutView!
    
    
    var initial = true

    // id: Pin -- reference to a followers map you've chosen to overlap with yours.
    
    var activeFollowersPins: [String:Pin] = [:]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        pinDetailButton.isHidden = true
        editPinButton.isHidden = true
        
        mapView.delegate = self

        setupLocation()
        setupETB()
        setupButtons()
        self.mapView.showsUserLocation = true
        self.mapView.showAnnotations(mapView.annotations, animated: true)
       
        self.mapView.setup()
        
        FirebaseService.updateUser(id: thisUserID) {
            
            // use intial to avoid calling this part of listener when user updates.
        
            
                ThisUser.instance?.getAllPins {
                    
                    if self.initial{
                        
                    
                    self.dropPins(pins: Array(ThisUser.instance!.pins.values))
                    self.initial = false
                    
                }
                    
            }
            
            
            

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    
    func setupButtons() {
        
        
        let inset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)

        let buttons: [UIButton] = [pinDetailButton, editPinButton]
        
        for b in buttons{
            
            
            b.layer.cornerRadius = b.frame.width/2
            b.contentMode = .scaleAspectFit
            b.imageEdgeInsets = inset
            
            b.layer.shadowRadius = 3
            b.layer.shadowOffset = CGSize(width: 0, height: 3)
            b.layer.shadowColor = UIColor.black.cgColor
            b.layer.shadowOpacity = 0.3
            
            
            if b == editPinButton {
                b.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
            }
            
        }
    }
    
    func updatePin(pinId: String){
        
        FirebaseService.getPin(id: pinId, completion: { pin in
        
            if let pin = pin{
                
                self.mapView.removePinWith(coordinate: pin.coordinate)
                self.dropPins(pins: [pin])
                
            }
        })
        
        
        
    }
    
    func dropPins(pins:[Pin]){
        
        // TODO: setup system where only pins not on map are added to it; instead of clearing and putting on.
        
        for p in pins {
            
            let point = LocusPointAnnotation()
            point.coordinate = p.coordinate
            point.iconName = p.iconName
            point.custom = true
            point.date = p.date.toString()
            point.name = ThisUser.instance?.name
            point.pinImage = p.image
            point.pinId = p.id

            
            if p.ownerId != ThisUser.instance!.id{
                point.foreign = true
                
                FirebaseService.getUserName(id: p.ownerId, completion: { name in
                    point.name = name
                })
                
            }
            
            else{
                
                self.mapView.addAnnotation(point)
                
            }
            
            self.mapView.addAnnotation(point)
            
        }
    }
    
    
    
    
    // MARK: Setup Functions
    func setupLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // SEARCH BAR
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
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
    
    
    func overlayFollowerMap(id:String){
        
        FirebaseService.getPinsForUser(id: id, local: false) { pins in
            
            
            for p in pins{
                self.activeFollowersPins[p.id!] = p
            }
            
            self.dropPins(pins: pins)
        }
    }
    
    func removeFollowerMap(id:String){
        
        // clear the maps reference to the pins by clearing dictionary
        self.activeFollowersPins.removeAll()
        
        // remove all annotation associated with the follower for given id
        for annotation in mapView.annotations {
            if let locusAnnotation = annotation as? LocusPointAnnotation{
                
                if locusAnnotation.foreign{
                    mapView.removeAnnotation(annotation)
                }
            }

        }
    }
    
    func removeTempAnnotation(){
        
        if let tempAnnotation = tempAnnotation{
            
            self.mapView.removeAnnotation(tempAnnotation)
        }
        
    }

    @IBAction func pinDetailsButton(_ sender: Any) {
        
        let detailVc = Helper.instantiateController(storyboardName: "EditPin", controllerName: "PinDetailController", bundle: nil) as! PinDetailController
        
        detailVc.pin = selectedPin
        
        self.present(detailVc, animated: true, completion: nil)
    }
    
    
    @IBAction func editPinButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "buildPin", sender: self)
        
        
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
                
                
                    let customAnnotationView = CustomAnnotationView(annotation: locusAnnotation, reuseIdentifier: "pin")
                    
                    customAnnotationView.frame.size = CGSize(width: 30, height: 30)
                    customAnnotationView.contentMode = .scaleAspectFit
                    
                    customAnnotationView.imageView.sd_setImage(with: FirConst.iconRef.child(locusAnnotation.iconName + "@3x.png"), placeholderImage: #imageLiteral(resourceName: "redGooglePin")) { image, error, cache, ref in
                        
    
                        customAnnotationView.image = image
                    }
                    
                    customAnnotationView.canShowCallout = false
                    customAnnotationView.pinId = locusAnnotation.pinId
                    
                    return customAnnotationView
            }
            
            else{
                
                self.tempAnnotation = annotation
                let standardPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "standardPin")
                standardPin.canShowCallout = true
                standardPin.animatesDrop = true
                return standardPin // returns here for when new basic pin added for first time

                
                
//                if pinView == nil{
//                    let standardPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "standardPin")
//                    standardPin.canShowCallout = true
//                    standardPin.animatesDrop = true
//                    return standardPin // returns here for when new basic pin added for first time
//                }
//                
//                else{
//
//                    return pinView
//                }
                
            }
        }

        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let customAnnotation = view.annotation as? LocusPointAnnotation else {return}
        
        if customAnnotation.custom {
            

            
            self.mapView.selectedMark = MKPlacemark(coordinate: customAnnotation.coordinate)

            let xib = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
            customView = xib?[0] as! CustomCalloutView
            
            // Set Fields for customView
            customView.dateLabel.text = customAnnotation.date
            customView.nameLabel.text = customAnnotation.name
            customView.pinImageView.image = customAnnotation.pinImage
            customView.pinId = customAnnotation.pinId
            
            var thisPin: Pin
            
            if customAnnotation.foreign {
                
                thisPin = activeFollowersPins[customAnnotation.pinId]!
            }
            
            else{
                
                thisPin = ThisUser.instance!.pins[customAnnotation.pinId]!

            }
            
            self.pinDetailButton.isHidden = false
            // hide the edit button if you do not own this pin
            self.editPinButton.isHidden = !(ThisUser.instance!.id == thisPin.ownerId)
            
            self.selectedPin = thisPin
            self.selectedAnnotation = view.annotation
            
            
            
//             load image for selected pin
            
            // TODO: This is freaking ridiculous
            
            print(SDImageCache.shared().diskImageExists(withKey: thisPin.imageRef!.fullPath))
            print(SDImageCache.shared().diskImageExists(withKey: String(describing: thisPin.imageRef!)))
            SDImageCache.shared().getDiskCount()

            
//            thisPin.imageRef!.downloadURL(completion: { url, error in
//                
//                if let url = url{
//                
//                    self.customView.pinImageView.sd_setImage(with: url, placeholderImage: UIImage(), options: .refreshCached, completed: { image, error, cache, url in
//                        
//                        // do stuff
//                    
//                    
//                    })
//                }
//                
//            })
            

            
  
            
            customView.pinImageView.sd_setImage(with: thisPin.imageRef!, maxImageSize: 1 * 1024 * 1024, placeholderImage: UIImage(), completion: { image, error, cache, ref in
                
                self.customView.pinImageView.image = image
            
            })
            
            

            
            customView.bounds.size = CGSize(width: 150, height: 150)
            customView.center = CGPoint(x: view.bounds.size.width / 2, y: -customView.bounds.size.height*0.52)
            

            // NOTE: ITS ADDING THE SUBVIEW TO THE ANNOTATION!

            view.addSubview(customView)
            
            self.panTo(coordinate: thisPin.coordinate, mapView: self.mapView)
            
        }
        
        else {
            
            self.selectedPin = nil
            
            let btnHeight = view.frame.height * 0.8
            let smallSquare = CGSize(width: btnHeight, height: btnHeight)
            
            let pinIt = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
            
            pinIt.contentMode = .scaleAspectFit
            
            pinIt.setBackgroundImage(#imageLiteral(resourceName: "pinMap_color"), for: .normal)
            
            
            pinIt.addTarget(self, action: #selector(self.goBuildPin), for: .touchUpInside)
            
            view.rightCalloutAccessoryView = pinIt
            

            
            self.selectedAnnotation = view.annotation
            view.canShowCallout = true
         
            
        }

    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let deselectedAnnotation = view as? CustomAnnotationView else {return}
        
        pinDetailButton.isHidden = true
        editPinButton.isHidden = true
        
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
        let uid = ThisUser.instance!.id
        var newPins = [Pin]()
        for photo in gpsPhotos{
            
            let newPin = Pin(ownerId: uid, coordinate: photo.location, image: photo.image)
            newPin.save(newAlbum: nil)
            newPins.append(newPin)
            
        }
        
        self.dropPins(pins: newPins)
    }
    
}


extension MapViewController: CustomCalloutDelegate {
    
    func viewDetails() {
        
        // present the detail VC when the pin image is selected
        
       let detailVc =  Helper.instantiateController(storyboardName: "Edit", controllerName: String(describing: PinDetailController.self), bundle: nil) as! PinDetailController
        
        detailVc.pin = selectedPin!
        
        present(detailVc, animated: true, completion: nil)
        
    }
}

// Mark: Setup for ETB
extension MapViewController {
    
    func setupETB() {
        
        
        let x = view.frame.width - 50
        let y = view.frame.height - 90 - 10  // 90 is for tab bar , approximate
        let frame = CGRect(x: x , y: y, width: 240, height: 40)
        let toolbar = ExpandingToolBar(frame: frame, buttonSize: 40)
        
//        toolbar.setExpandButtonImage(image: #imageLiteral(resourceName: "logo-mini"))
        
        toolbar.direction = .north
        
        let font = UIFont(name: "Helvetica", size: 20)
        

        toolbar.addAction(title: "", font: nil, image: #imageLiteral(resourceName: "pinMap_color"), color: UIColor.gray, action: getGPSPhotos)
        
        toolbar.addAction(title: "", font: nil, image: #imageLiteral(resourceName: "camera_color"), color: UIColor.gray, action: takePhoto)
        
        toolbar.addAction(title: "", font: nil, image: #imageLiteral(resourceName: "target_color"), color: UIColor.gray, action: findMe)
        
        
        toolbar.addAction(title: "", font: nil, image: #imageLiteral(resourceName: "map_color"), color: .gray, action: changeMap)
        
        toolbar.addAction(title: "", font: font, image: #imageLiteral(resourceName: "man-and-opened-exit-door"), color: UIColor.gray, action: signOut)

        
        self.view.addSubview(toolbar)
    }
    
    func signOut(){
        
        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func getGPSPhotos(){
        
        self.performSegue(withIdentifier: "photoLibrary", sender: self)

    }
    
    func findMe(){
        
        if let currentPosition = currentPosition {
            
            panTo(coordinate: currentPosition.coordinate, mapView: self.mapView)
        }
    }
    
    func takePhoto(){
        
        presentAlerts()
        
    }
    
    func changeMap() {
        
       let alert = UIAlertController(title: "Select a map type", message: nil, preferredStyle: .actionSheet)
        
        let mapTypes : [MKMapType] = [.standard, .satellite, .hybrid, .satelliteFlyover, .hybridFlyover]
        
        for type in mapTypes{
            let action = UIAlertAction(title: mapTypeString(type: type), style: .default, handler: { action in
                
                self.mapView.mapType = type
            })
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // TODO: Put into protocol or extension
    func mapTypeString(type: MKMapType) -> String{
        
        switch(type){
        case .standard:
            return "standard"
        case .satellite:
            return "satellite"
        case .hybrid:
            return "hybrid"
        case .satelliteFlyover:
            return "satellite flyover"
        case .hybridFlyover:
            return "hybrid flyover"
        }
    }
    
}
