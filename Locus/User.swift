//
//  User.swift
//  Locus
//
//  Created by Nabil K on 2016-12-17.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import Foundation
import Firebase

class User{
    var name:String
    var id: String
    var friendRefs: [String]?
    var pinIds: [String] = []
    var pins: [Pin] = []
    var reference: FIRDatabaseReference?
    
    init(name:String, id:String){
        self.name = name
        self.id = id
    }
    
    init(snapshot: FIRDataSnapshot){
        
        self.id = snapshot.key
        self.reference = snapshot.ref
        let snapshotValue = snapshot.value as! [String:AnyObject]
        
        if let nameData = snapshotValue["name"] {
            self.name = nameData as! String
        }
        
        else{self.name = ""}
        
        if let friendData = snapshotValue["friendRefs"]{
            self.friendRefs = friendData as? [String]
        }
        
        if let pinIdData = snapshotValue["pinRefs"]{
            self.pinIds = pinIdData as! [String]
        }
    }
    
    func getAllPins(){
        
        let pinRef = FIRDatabase.database().reference(withPath: "pins")
        pinRef.observe(.value, with: { snapshot in
            for item in snapshot.children{
                let pinData = item as! FIRDataSnapshot
                let newPin = Pin(snapshot: pinData, ownerId: self.id)
                self.pins.append(newPin)
            }
            })
        }
    
    func getPinWithId(pinId: String, completion: ((Pin) -> Void)?) {
        let thisPinRef = FIRDatabase.database().reference(withPath: "pins").child(pinId)
        thisPinRef.observe(.value, with:{ snapshot in
            let newPin = Pin(snapshot: snapshot, ownerId: self.id)
            self.pins.append(newPin)
            completion(newPin)
        })
        
    }

}



//class Permission {
//    var fromUser: String
//    var toUser: String
//    
//    init(fromUser:String, toUser: String){
//        self.fromUser = fromUser
//        self.toUser = toUser
//    }
//
//}


enum Privacy:Int {
    case personal = 2
    case friends = 1
    case pub = 0
}
