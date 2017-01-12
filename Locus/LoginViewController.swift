//
//  LoginViewController.swift
//  Locus
//
//  Created by Nabil K on 2016-12-23.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    var userRef:FIRDatabaseReference?
    var nameAlert:UIAlertController?
    var nameTakenAlert:UIAlertController
    var nameFormatAlert:UIAlertController

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userRef = FIRDatabase.database().reference(withPath: "users")
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        if let currentUser = GIDSignIn.sharedInstance().currentUser{
            //Stuff to do if you have a user
        }
            
        else {
            signUp()
        }
    
    }
    
    func getUserName(){
        
        if let id = FIRAuth.auth()?.currentUser?.uid{
            let nameQuery = userRef!.child(id)
            
            nameQuery.observe(.value, with: { snapshot in
                if snapshot.hasChildren(){
                    self.performSegue(withIdentifier: "map", sender: self)
                }
                else{
                    self.present(self.nameAlert!, animated: true, completion: nil)
                }
            })
        }
    }

    
    func signUp(){
         nameAlert = UIAlertController(title: "Welcome to Locus!", message: "What is your name?", preferredStyle: .alert)
        let nameFormatAlert = UIAlertController(title: "Name Error", message: "", preferredStyle: .alert)
        let nameTakenAlert = UIAlertController(title: "Please select another name", message: "Sorry that username has already been taken", preferredStyle: .alert)
        
        
        let retryNameAction = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.present(nameAlert, animated: true, completion: nil)
        })
        
        
        
        let submitNameAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            let name = nameAlert.textFields![0].text ?? ""
            let characters = name.characters
            // Check if userName exists in Firebase
            
            
            if characters.count < 2 || name.characters.contains(" "){
                self.present(nameFormatAlert, animated: true, completion: nil)
            }
                
            else{
                let nameQuery = self.userRef!.queryOrdered(byChild: "name").queryEqual(toValue: "name")
                nameQuery.observe(.value, with: { snapshot in
                    if snapshot.hasChildren(){
                        self.present(nameTakenAlert, animated: true, completion: nil)
                    }
                    
                    else{
                        let newRef = self.userRef!.childByAutoId().child("name")
                        newRef.setValue(name)
                    }
                })
            }
        })
        
        nameAlert.addAction(retryNameAction)
        nameFormatAlert.addAction(retryNameAction)
        nameTakenAlert.addAction(retryNameAction)
        
        // Make Textfields next
    }
    
    
    

    @IBAction func didTapSignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }
    

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        print("stop here")
        if let error = error {
            // ...
            print("signed in")
            print("\n")
            print("\n")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("reached here")
            print(user?.displayName)
            // ...
            if let error = error {
                // ...
                return
            }
            
            
            self.performSegue(withIdentifier: "toMap", sender: self)
        }
    }

    


}
