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
    var iconName: String = "default"
    var privacy: Privacy = .pub
    var date: Date = Date()
    var albumName = ""
    var albumId = ""
    var coordinate: CLLocationCoordinate2D?

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
            self.imageRef = imageRefData as! FIRStorageReference
        }
        
        if let latData = snapshotValue["lat"], let lonData = snapshotValue["lon"]{
            let lat = latData as! CLLocationDegrees
            let lon = latData as! CLLocationDegrees
            self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        
        if let dateData = snapshotValue["date"]{
            let dateString = dateData as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            self.date = dateFormatter.date(from: dateString)!
        }
        
    
        
        
    }
    
    func save(newAlbum: String?){
        if let ref = self.reference{
            ref.setValue(self)
            if let image = self.image{
                let upload = imageRef?.put(image.toData())
            }
            //saveImageHere
        }
        else{
            let pinRef = FIRDatabase.database().reference().child("pins").childByAutoId()
            pinRef.observe(.childAdded, with: { snapshot in
                self.id = snapshot.key
                self.imageRef = self.storage.child(snapshot.key)
                if let image = self.image{
                    self.imageRef!.put(image.toData())
                }
            })
            
            if let newAlbum = newAlbum {
                changeAlbum(oldAlbumKey: self.albumId, newAlbumKey: newAlbum)
            }
            pinRef.setValue(self)
        }
        
    
        
        //save image here instead?
    }
    
    func changeAlbum(oldAlbumKey: String, newAlbumKey: String) {
        let firebaseAlbums = FIRDatabase.database().reference().child("albums")
        let oldRef = firebaseAlbums.child(oldAlbumKey).child("pinIds").child(self.id!)
        oldRef.removeValue()
        
        // TODO: This solution is stupid. Think of something better
        let newRef = firebaseAlbums.child(newAlbumKey).child("pinIds").child(self.id!)
        newRef.setValue(self.id)
        
        self.albumId = newAlbumKey
    }
    

    
    func getImage(completion: @escaping (UIImage) -> Void){
        
        let imagesRef = FIRStorage.storage().reference(withPath: "images")
        
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
    
    
    
    
    
}
