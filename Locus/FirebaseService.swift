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
        reference.observeSingleEvent(of: .value, with: { snapshot in
            let user = User(snapshot: snapshot)
            ThisUser.instance = user
            completion()
        })
    }
    
    
    // Mark: Follower Functions
    
    static func getUserName(id:String, completion: @escaping (String) -> ()){
    
        let query = FirConst.userRef.child(id).child(FirConst.name)
        
        query.observeSingleEvent(of: .value, with : { snapshot in
            
            let name = snapshot.value as! String
            
            completion(name)
            
        })
    
    }
    
    static func getFollowerData(id:String, completion: @escaping (String) -> ()){
        let query = FirConst.userRef.queryOrdered(byChild: "permissions").queryEqual(toValue: id)
        
        query.observe(.value, with: { snapshot in
            let data = snapshot.value as! [String:Any]
            let name = data[FirConst.name] as! String
            completion(name)
        })
    }
    
    static func updateFollowerStatus(id: String, completion: @escaping ([String: Bool]) -> () ){
        let query = FirConst.userRef.child(id).child(FirConst.following)
        
        query.observe(.value, with: { snapshot in
            
            let data = snapshot.value as! [String:Bool]
            completion(data)
            
        
        })
        
        
    }
    
    
    
    static func getPendingRequests(ids:[String], completion: @escaping ([Identity]) -> ()){
        
        var userInfo = [Identity]()
        let output_dispatch = DispatchGroup()

        
        for id in ids {
            output_dispatch.enter()
            FirConst.userRef.child(id).observeSingleEvent(of: .value, with: { snapshot in
                let user = User(snapshot: snapshot)
                let identity = Identity(name: user.name, id: user.id)
                userInfo.append(identity)
                output_dispatch.leave()

            })

            
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
            
            
            FirConst.userRef.child(key).observe(.value, with: { snapshot in
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
    
    static func unfollowUser(followingUserId: String, followedUserId: String, completion: @escaping () -> ()){
        
        FirConst.userRef.child(followingUserId).child(FirConst.following).child(followingUserId).removeValue()
        
    }
    
    
    // MARK: Pin Functions
    static func getPinsForUser(id:String, local: Bool, completion: @escaping ([Pin]) -> ()){
        let query = FirConst.pinRef.queryOrdered(byChild: FirConst.ownerId).queryEqual(toValue: id)
        
        var pins = [Pin]()
                
        query.observeSingleEvent(of: .value, with: { snapshot in
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
    
    
    static func deletePin(for userId: String, pinId: String, completion: @escaping () -> () ){
        let queryForPin = FirConst.pinRef.child(pinId)
        let queryForUser = FirConst.userRef.child(userId).child(FirConst.pinIds).child(pinId)

        queryForPin.removeValue()
        
        // TODO: Take care of error handling here
        queryForUser.removeValue { error, ref in
            if error != nil{
                print("an error occurred with deleting this information")
            }
            
            completion()
            
        }
    }
    
    
    
    // Flag Operation
    
    static func saveFlag(flag:Flag){
        FirConst.flagRef.childByAutoId().setValue(flag.toAnyObject())
    }
    
    
}

struct Identity{
    var name: String
    var id: String
}
