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
    var nameAlert:UIAlertController!
    var nameTakenAlert:UIAlertController!
    var nameFormatAlert:UIAlertController!
    
    var id:String?
    var usernameQuery:FIRDatabaseReference?

    
    
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
            self.usernameQuery = userRef?.child("\(id)")
            usernameQuery!.observe(.value, with: { snapshot in
                if snapshot.hasChild("name"){
                    self.performSegue(withIdentifier: "map", sender: self)
                }
                else{
                    self.present(self.nameAlert!, animated: true, completion: nil)
                }
            })
        }
    }

    
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }
    

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
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

            print(user?.displayName)
            // ...
            if let error = error {
                // ...
                return
            }
            self.getUserName()
        }
    }

    


}
