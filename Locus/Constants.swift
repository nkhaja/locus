//
//  Constants.swift
//  Locus
//
//  Created by Nabil K on 2017-02-26.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct FirConst {
    
    static let ref = FIRDatabase.database().reference()
    static let userRef = ref.child("users")
    static let pinRef = ref.child("pins")
    

    
    static let storageRef  = FIRStorage.storage().reference()
    static let iconRef = storageRef.child("icons")
    
    // Users
    static let name = "name"
    static let id = "id"
    static let following = "following"
    static let permissionsWaiting = "permissionsWaiting"
    static let privacy = "privacy" //also in Pins
    static let pins = "pins"
    static let pinIds = "pinIds"
    static let albumIds = "albumIds"
    
    
    // Pins
    static let title = "title"
    static let placeName = "placeName"
    static let story = "story"
    static let date = "date"
    static let lat = "lat"
    static let lon = "lon"
    static let iconName = "iconName"
    static let imageRef = "imageRef"
    
    static let ownerId = "ownerId"
    static let albumName = "albumName"
    static let albumId = "albumId"
    
    //Flags
    
    static let flagRef = ref.child("flags")
    
}


struct ThisUser {
    
    static var instance: User?
    static var thisUserId = FIRAuth.auth()?.currentUser!.uid

}
