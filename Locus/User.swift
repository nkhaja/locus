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
    var friendIds: [String:Bool] = [:]
    var pinIds: [String: Bool] = [:]
    var albumIds: [String] = []
    var pins = [String:Pin]()
    var following = [String: Bool]() // a list of userIDs for users this person is following
    var reference: FIRDatabaseReference?
    var accountPrivacy: AccountPrivacy = .permission
    
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
        
        if let friendData = snapshotValue["friendIds"]{
            self.friendIds = friendData as! [String:Bool]
        }
        
        if let pinIdData = snapshotValue["pinRefs"]{
            self.pinIds = pinIdData as! [String:Bool]
        }
    }
    
    func getAllPins(completion: @escaping () -> ()){
        
        let pinRef = FIRDatabase.database().reference(withPath: "pins")
        pinRef.observe(.value, with: { snapshot in
            for item in snapshot.children{
                let pinData = item as! FIRDataSnapshot
                let newPin = Pin(snapshot: pinData, ownerId: self.id)
                self.pins[pinData.key] = newPin
                completion()
            }
            })
        }
    
    func getPinWithId(pinId: String, completion: @escaping ((Pin) -> Void)) {
        let thisPinRef = FIRDatabase.database().reference(withPath: "pins").child(pinId)
        thisPinRef.observe(.value, with:{ snapshot in
            let newPin = Pin(snapshot: snapshot, ownerId: self.id)
            self.pins[snapshot.key] = newPin
            
            completion(newPin)
        })
        
    }

    
    func toAnyObject() -> NSDictionary{
        
        var albumIdDict: [String:String] = [:]
        albumIds.map({albumIdDict[$0] = $0})
        
    
        return [
            "name": name,
            "id": id,
            "friendIds": friendIds,
            "pinIds": pinIds,
            "albumIds": albumIdDict,
            "accountPrivacy": accountPrivacy.rawValue
        ]
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

enum AccountPrivacy:Int {
    case open = 0
    case permission = 1
    case closed = 2
}
