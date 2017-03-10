//
//  Pin.swift
//  Locus
//
//  Created by Nabil K on 2016-12-19.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import Foundation
import Firebase
import MapKit

// TODO: Prevent location collisions

class Pin {
    
    var title: String = ""
    var placeName: String = ""
    var story:String = ""
    var ownerId: String = ""
    var iconName: String = "redGooglePin"
    var privacy: Privacy = .pub
    var date: Date = Date()
    var albumName = ""
    var albumId = ""
    var coordinate: CLLocationCoordinate2D

    var imageRef: FIRStorageReference?
    var image: UIImage?
    var id:String?
    var reference: FIRDatabaseReference?
    let storage: FIRStorageReference = FIRStorage.storage().reference(withPath: "images")
    
    
    init(title:String, ownerId: String, coordinate:CLLocationCoordinate2D){
        self.title = title
        self.ownerId = ownerId
        self.coordinate = coordinate
    }
    
    // For initializing GPSimages in batches out of the library
    init(ownerId:String, coordinate: CLLocationCoordinate2D, image: UIImage){
        self.ownerId = ownerId
        self.coordinate = coordinate
        self.image = image
    }
    
    init(snapshot: FIRDataSnapshot, ownerId: String?){
        self.id = snapshot.key
        self.reference = snapshot.ref
        let snapshotValue = snapshot.value as! [String:AnyObject]
        
        if let titleData = snapshotValue["title"]{
            self.title = titleData as! String
        }
        
        if let placeData = snapshotValue["placeName"]{
            self.placeName = placeData as! String
        }
        
        if let descriptionData = snapshotValue["story"]{
            self.story = descriptionData as! String
        }
        
        if let iconName = snapshotValue["iconName"]{
            self.iconName = iconName as! String
        }
        
        if let ownerIdData = snapshotValue["ownerId"]{
            self.ownerId = ownerIdData as! String
        }
        
        if let imageRefData = snapshotValue["imageRef"]{
            self.imageRef = (imageRefData as! FIRStorageReference)
        }
        
        let lat = snapshotValue["lat"] as! String

        
        let lon = snapshotValue["lon"] as! String
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lon)!)


        if let dateData = snapshotValue["date"]{
            let dateString = dateData as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            self.date = dateFormatter.date(from: dateString)!
        }
        
        self.imageRef = storage.child(id!)
    }
    
    func save(newAlbum: String?){
        // previously saved object
        if let ref = self.reference {
            
            ref.setValue(self.toAnyObject())
         
            
            //pin has an image to store
            if let image = self.image, let imageRef = imageRef{
                imageRef.put(image.toData())
            }
            //saveImageHere
        }
        //object being saved for the first time
        else{
            let db = FIRDatabase.database().reference()
            let pinRef = db.child("pins").childByAutoId()
            self.id = pinRef.key
            let userRef = db.child("users").child(ownerId).child("pinIds").child(self.id!)
            
            userRef.setValue(true)
            
            self.imageRef = self.storage.child(self.id!)
            if let image = self.image{
                self.imageRef!.put(image.toData())
                // TODO: a second condition to avoid uploading unchanged pics
            }
            
            
            
            //There is a new album being assigned
            if let newAlbum = newAlbum {
                changeAlbum(oldAlbumKey: self.albumId, newAlbumKey: newAlbum)
            }
            
            
            if self.placeName == "" {
                
                reverseGeoLocation(coordinate: coordinate){ place in
                    self.placeName = place
                    pinRef.setValue(self.toAnyObject())
                }
                return
            }
            
            pinRef.setValue(self.toAnyObject())
        }
        
        //save image here instead?
    }
    
    
    //Remove reference in old album, move to new album, assign new album Id to this pin
    func changeAlbum(oldAlbumKey: String, newAlbumKey: String) {
        
        let firebaseAlbums = FIRDatabase.database().reference().child("albums")
        let oldRef = firebaseAlbums.child(oldAlbumKey).child("pinIds").child(self.id!)
        oldRef.removeValue()
        
        // TODO: This solution is stupid. Think of something better
        let newRef = firebaseAlbums.child(newAlbumKey).child("pinIds").child(self.id!)
        newRef.setValue(self.id)
        
        self.albumId = newAlbumKey
    }
    

    // get the image for this pin
    func getImage(completion: @escaping (UIImage) -> Void){
        
        if let imageRef = self.imageRef {
            imageRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
                if let error = error {
                    print("image too large")
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    self.image = UIImage(data: data!)
                    completion(self.image!)
                }
            }
        }
    }
    
    
    func reverseGeoLocation(coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> ()) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil{
                print("Reverse geocoder failed with error" + error!.localizedDescription)
            }
            
            if placemarks!.count > 0{
                let placemark = placemarks![0]
                var name = placemark.name! //+ ", " + pm.subThoroughfare!
                if let city = placemark.locality, let state = placemark.administrativeArea{
                    name = name + ", \(city) \(state)"
                    
                }
                
                completion(name)
            }
                
            else{
                completion("Unregistered Location")
            }
        }
    }
    
    
    func delete(completion: @escaping () -> ()) {
        
        FirebaseService.deletePin(for: self.ownerId, pinId: self.id!, completion: {
            completion()
        })
    
    }
    
   func toAnyObject() -> NSDictionary {
        return [
            "title": title,
            "placeName": placeName,
            "story": story,
            "ownerId": ownerId,
            "iconName": iconName,
            "privacy": privacy.rawValue,
            "date": date.toString(),
            "albumName": albumName,
            "albumId": albumName,
            "lat": String(coordinate.latitude),
            "lon": String(coordinate.longitude)
        ]
    }
}


extension Pin: Comparable {

    static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    static func < (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.title < rhs.title
    }

}


struct Flag {
    
    var fromUser: String
    var toUser: String
    var pinId: String
    
    
    init(fromUser: String, toUser: String, pinId: String){
        
        self.fromUser = fromUser
        self.toUser = toUser
        self.pinId = pinId
    }
    
    
    func save(){
        
        FirebaseService.saveFlag(flag: self)
        
    }
    
    func toAnyObject() -> [String: String]{
        
        return [
            
            "fromUser" : fromUser,
            "toUser" : toUser,
            "pinId" : pinId
            
        ]
        
        
    }
    
}

    



    
    
    
    

