//
//  Album.swift
//  Locus
//
//  Created by Nabil K on 2017-01-12.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
import Firebase

class Album{
    var name: String
    var ownerId: String
    var description: String = ""
    var pinIds:[String] = []
    var pins: [Pin] = []
    
    var id: String?
    var ref: FIRDatabaseReference?
    
    
    init(name:String, ownerId: String){
        self.name = name
        self.ownerId = ownerId
    }
    
    init(snapshot: FIRDataSnapshot){
        ref = snapshot.ref
        id = snapshot.key
        let snapshotValue = snapshot.value as! [String:AnyObject]
        self.name = snapshotValue["name"] as! String
        self.ownerId = snapshotValue["ownerId"] as! String
        
        if let nameData = snapshotValue["name"] {
            self.name = nameData as! String
        }
        
        if let ownerIdData = snapshotValue["ownerId"] {
            self.ownerId = ownerIdData as! String
        }
        
        if let descriptionData = snapshotValue["description"] {
            self.description = descriptionData as! String
        }
        
        if let pinIdsData = snapshotValue["pinIds"] {
            self.pinIds = pinIdsData as! [String]
        }
    }
    

    func toAnyObject() -> NSDictionary{
        return[
        
        "name":name,
        "ownerId":ownerId,
        "description": description,
        
        
        
        ]
    }
    
    
    
    
}
