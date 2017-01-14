//
//  BuildPinViewController.swift
//  Locus
//
//  Created by Nabil K on 2017-01-03.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class BuildPinViewController: UIViewController {


    var pin: Pin?
    var placeName: String!
    var location: CLLocationCoordinate2D!
    var thisUserId:String = FIRAuth.auth()!.currentUser!.uid
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var iconName: String = "default"

    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var iconButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
        if let pin = self.pin{
            self.pinImage.image = pin.image!
            let thisIcon = UIImage(named: pin.iconName)
            self.iconButton.setImage(thisIcon, for: .normal)
            
            self.titleTextField.text! = pin.title
            self.placeNameTextField.text! = pin.placeName
            self.dateLabel.text! = pin.date.toString()
            self.albumLabel.text! = pin.albumName
            self.storyTextView.text! = pin.story
            self.placeName = pin.placeName
            self.iconName = pin.iconName
        }
        
        else{
            self.iconButton.setImage(#imageLiteral(resourceName: "redGooglePin"), for: .normal)
            placeNameTextField.text! = self.placeName
            dateLabel.text! = Date().toString()
            albumLabel.text! = "No Album Selected"
        }
        

        // Do any additional setup after loading the view.
    }
    
    func makePin(pin:Pin) -> Pin{
        pin.title = titleTextField.text!
        pin.placeName = placeNameTextField.text!
        pin.albumName = albumLabel.text!
        pin.date = dateLabel.text!.toDate()
        pin.story = storyTextView.text!
        pin.iconName = self.iconName
        
        return pin
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    @IBAction func selectIconButton(_ sender: UIButton) {
        performSegue(withIdentifier: "seeIcons", sender: self)
    }
    
    @IBAction func dateButton(_ sender: UIButton) {
        //Get the date view
    }
    
    @IBAction func albumButton(_ sender: UIButton) {
        //get the album view
    }
    

    @IBAction func savePin(_ sender: UIButton) {
        
        
        if let pin = self.pin{
            let updatedPin = makePin(pin: pin)
            updatedPin.save()
            //TODO: change to Any Object
            
        }
        
        else{
            let title = titleTextField.text
            let pinToBuild = Pin(title: title!, ownerId: self.thisUserId, coordinate: location)
            let newPin = makePin(pin:pinToBuild)
            newPin.save()
        }
        
    }
    
    


    
    
}


//Handle keyboard

extension BuildPinViewController {
    
    func setupKeyboard(){
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: Notification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    
    func keyboardWillShow(notification: Notification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification: Notification) {
        adjustInsetForKeyboardShow(show: false, notification: notification)
    }
 
    
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return changePicBtn
//    }
//    
//    func scrollViewDidZoom(scrollView: UIScrollView) {
//        updateConstraintsForSize(size: view.bounds.size)
//    }
//    
//    
//    private func updateMinZoomScaleForSize(size: CGSize) {
//        let widthScale = size.width / changePicBtn.bounds.width
//        let heightScale = size.height / changePicBtn.bounds.height
//        let minScale = min(widthScale, heightScale)
//        
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//    }
//    
//    private func updateConstraintsForSize(size: CGSize) {
//        
//        let yOffset = max(0, (size.height - changePicBtn.frame.height) / 2)
//        imageBtnTopConstraint.constant = yOffset
//        imageBtnBottomConstraint.constant = yOffset
//        
//        let xOffset = max(0, (size.width - changePicBtn.frame.width) / 2)
//        imageBtnLeadingConstraint.constant = xOffset
//        imageBtnTrailingConstraint.constant = xOffset
//        
//        view.layoutIfNeeded()
//    }
    
}

