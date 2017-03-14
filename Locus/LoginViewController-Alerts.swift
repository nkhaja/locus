//
//  LoginViewController-Alerts.swift
//  Locus
//
//  Created by Nabil K on 2017-01-12.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
import Firebase
import UIKit

extension LoginViewController{
    
    
    func signUp(){
        nameAlert = UIAlertController(title: "Welcome to Locus!", message: "What is your name?", preferredStyle: .alert)
        let nameFormatAlert = UIAlertController(title: "Name Error", message: "Please make sure you name is at least 4 characters long with no spaces", preferredStyle: .alert)
        let nameTakenAlert = UIAlertController(title: "Please select another name", message: "Sorry that username has already been taken", preferredStyle: .alert)
        
        
        let retryNameAction = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.present(self.nameAlert!, animated: true, completion: nil)
        })
        
        
        
        let submitNameAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            let name = self.nameAlert!.textFields![0].text ?? ""
            let characters = name.characters
            let id = FIRAuth.auth()!.currentUser!.uid
            
            //check that name is valid
            if characters.count < 4 || name.characters.contains(" "){
                self.present(nameFormatAlert, animated: true, completion: nil)
            }
                
            else{
                let nameQuery = self.userRef!.child(id).child("name")
                nameQuery.observe(.value, with: { snapshot in
                    if snapshot.hasChildren(){
                        self.present(nameTakenAlert, animated: true, completion: nil)
                    }
                        
                    else{
                        let newRef = self.userRef!.child(id).child("name")
                        newRef.setValue(name)
                        self.performSegue(withIdentifier: "map", sender: self)
                    }
                })
            }
        })
        
        nameAlert.addAction(submitNameAction)
        nameFormatAlert.addAction(retryNameAction)
        nameTakenAlert.addAction(retryNameAction)
        
        //Textfields
        nameAlert.addTextField { textfield in
            textfield.placeholder = "Pick an username"
        }
    }
    
    
}
