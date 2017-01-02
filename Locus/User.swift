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
    var friends: [String]?
    var pins: [Pin]?
    
    init(name:String, id:String){
        self.name = name
        self.id = id
    }
}



class Pin {
    
    var title: String
    var description:String
    var ownerId: String
    var privacy: Privacy = .pub
    var permissions: [Permission]?
    var imageRef: String?
    
    
    init(title:String, description: String, ownerId: String){
        self.title = title
        self.description = description
        self.ownerId = ownerId
    }
    
}


class Permission {
    var fromUser: String
    var toUser: String
    
    init(fromUser:String, toUser: String){
        self.fromUser = fromUser
        self.toUser = toUser
    }

}


enum Privacy:String {
    case personal = "personal"
    case friends = "friends"
    case pub = "public"
}
