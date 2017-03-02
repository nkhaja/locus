//
//  FirebaseService.swift
//  Locus
//
//  Created by Nabil K on 2017-02-26.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FirebaseService {
    
    static func updateUser(id:String, completion: @escaping () -> ()){
        let reference = FirConst.userRef.child(id)
        reference.observe(.value, with: { snapshot in
            let user = User(snapshot: snapshot)
            ThisUser.instance = user
            completion()
        })
    }
    
    
    // Mark: Follower Functions
    
    static func getFollowerData(id:String, completion: @escaping (String) -> ()){
        let query = FirConst.userRef.queryOrdered(byChild: "id").queryEqual(toValue: id)
        
        query.observe(.value, with: { snapshot in
            let data = snapshot.value as! [String:Any]
            let name = data[FirConst.name] as! String
            completion(name)
        })
    }
    
    
    // TODO: Test this functionality
    static func getPendingRequests(user: User, completion: @escaping ([(id:String,name:String)]) -> ()){
        
        let output_dispatch = DispatchGroup()
        
        var userInfo = [(id:String, name:String)]()
        
        for key in user.permissionsWaiting.keys {
            output_dispatch.enter()
            FirConst.userRef.child(key).observe(.value, with: { snapshot in
                let user = User(snapshot: snapshot)
                userInfo.append((user.id, user.name))
            })
            
            output_dispatch.leave()
        }
        
        output_dispatch.notify(queue: .main) { 
            completion(userInfo)
        }
    }
    
    
    static func getUsersFollowing(user:User, completion: @escaping ([Identity]) -> ()){
        
        let output_dispatch = DispatchGroup()
        var identities = [Identity]()
        
        for key in user.following.keys {
            
            output_dispatch.enter()
            
            
            FirConst.userRef.child(key).observeSingleEvent(of: .value, with: { snapshot in
                let snapshotValue = snapshot.value as! [String:Any]
                let name = snapshotValue["name"] as! String
                let identity = Identity(name: name, id: key)
                
                identities.append(identity)
                
                output_dispatch.leave()
            })
        }
        
        output_dispatch.notify(queue: .main) { 
            completion(identities)
        }

    }
    
    
    // MARK: Pin Functions
    static func getPinsForUser(id:String, local: Bool, completion: @escaping ([Pin]) -> ()){
        let query = FirConst.pinRef.queryOrdered(byChild: FirConst.ownerId).queryEqual(toValue: id)
        
        var pins = [Pin]()
        query.observe(.value, with: { snapshot in
            for pinSnap in snapshot.children{
                
                let pinData = pinSnap as! FIRDataSnapshot
                let pin = Pin(snapshot: pinData, ownerId: nil)
                
                if local {
                    pins.append(pin)
                }
                
                else if pin.privacy != .personal {
                    pins.append(pin)
                }
            }
            completion(pins)
        })
    }
    
    static func getPin(id:String, completion: @escaping (Pin?) -> ()){
        let query = FirConst.pinRef.child(id)
        query.observe(.value, with: { snapshot in
            let newPin = Pin(snapshot: snapshot, ownerId: nil)
            
            if newPin.privacy != .personal{
                completion(newPin)
            }
        })
    }
    
}

struct Identity{
    var name: String
    var id: String
}
