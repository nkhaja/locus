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
        
        if let ownerId = ownerId{
            self.ownerId = ownerId
        }
        
        if let imageRefData = snapshotValue["imageRef"]{
            self.imageRef = (imageRefData as! FIRStorageReference)
        }
        
        let lat = snapshotValue["lat"] as! CLLocationDegrees
        let lon = snapshotValue["lon"] as! CLLocationDegrees
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)


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
        if let ref = self.reference{
            ref.setValue(self.toAnyObject())
            
            //pin has an image to store
            if let image = self.image, let imageRef = imageRef{
                imageRef.put(image.toData())
            }
            //saveImageHere
        }
        //object being saved for the first time
        else{
            let pinRef = FIRDatabase.database().reference().child("pins").childByAutoId()
            
            self.id = pinRef.key
            self.imageRef = self.storage.child(self.id!)
            if let image = self.image{
                self.imageRef!.put(image.toData())
                // TODO: a second condition to avoid uploading unchanged pics
            }
            
            
            
            //There is a new album being assigned
            if let newAlbum = newAlbum {
                changeAlbum(oldAlbumKey: self.albumId, newAlbumKey: newAlbum)
            }
            
           
            
            //Save to Firebase
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
            imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    self.image = UIImage(data: data!)
                    completion(self.image!)
                }
            }
        }
        

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
