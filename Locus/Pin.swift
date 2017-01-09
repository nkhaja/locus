//
//  Pin.swift
//  Locus
//
//  Created by Nabil K on 2016-12-19.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import Foundation
import Firebase

class Pin {
    
    var title: String = ""
    var description:String = ""
    var ownerId: String = ""
    var privacy: Privacy = .pub
//    var permissions: [String]?
    var imageRef: FIRStorageReference?
    var image: UIImage?
    var id:String?
    var reference: FIRDatabaseReference?
    
    
    init(title:String, description: String, ownerId: String){
        self.title = title
        self.description = description
        self.ownerId = ownerId
    }
    
    init(snapshot: FIRDataSnapshot, ownerId: String?){
        self.id = snapshot.key
        self.reference = snapshot.ref
        let snapshotValue = snapshot.value as! [String:AnyObject]
        
        if let titleData = snapshotValue["title"]{
            self.title = titleData as! String
        }
        
        if let descriptionData = snapshotValue["description"]{
            self.description = descriptionData as! String
        }
        
        if let ownerId = ownerId{
            self.ownerId = ownerId
        }
        
        if let imageRefData = snapshotValue["imageRef"]{
            self.imageRef = imageRefData as! FIRStorageReference
        }
    }
    
    func getImage(){
        
        let imagesRef = FIRStorage.storage().reference(withPath: "images")
        
        if let imageRef = self.imageRef {
            imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    self.image = UIImage(data: data!)
                }
            }
        }
        

    }
    
    
    
    
    
}
