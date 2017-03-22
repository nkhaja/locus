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
import SDWebImage

class BuildPinViewController: UIViewController {

    var pin: Pin?
    var placeName: String?
    var location: CLLocationCoordinate2D!
    var thisUserId:String = ThisUser.instance!.id
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var iconName: String = "redGooglePin"
    let datePicker = UIDatePicker()
    
    // Vars for pickerView transitions
    var albumData: [(String, String)] = []
    var selectedAlbumId: String?
    
    // vars for keyboard
    
    var insetsExpanded = false

    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
//    @IBOutlet weak var albumLabel: UILabel!
//    @IBOutlet weak var albumTextField: UITextField!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var privacySegmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        placeNameTextField.delegate = self
        
        
        //Setup
        setupKeyboard()
        setupGestures()
        setupStoryTextView()
        
        
        //Set datePicker as Input for dateTextfield
        dateTextField.delegate = self
        
        
        
        //Setup if pre-existing pin
        if let pin = self.pin{
            self.pinImage.sd_setImage(with: pin.imageRef!)
            
//            let thisIcon = UIImage(named: pin.iconName)
//            self.iconButton.setImage(thisIcon, for: .normal)
            
            
            iconButton.imageView?.sd_setImage(with: FirConst.iconRef.child(pin.iconName + "@3x.png"), placeholderImage: nil){
                
                image, error, cache, ref in
                
                self.iconButton.setImage(image, for: .normal)

                
            }
            
            self.titleTextField.text! = pin.title
            self.placeNameTextField.text! = pin.placeName
            self.dateTextField.text! = pin.date.toString()
//            self.albumTextField.text! = pin.albumName
            self.storyTextView.text! = pin.story
            self.storyTextView.textColor = UIColor.black
            self.placeName = pin.placeName
            self.iconName = pin.iconName
            
        }
        
        //Setup if new pin
        else{
            self.iconButton.setImage(#imageLiteral(resourceName: "redGooglePin"), for: .normal)
            placeNameTextField.text! = self.placeName!
            dateTextField.text! = Date().toString()
//            albumTextField.text! = "No Album Selected"
        }
        
        self.iconButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func makePin(pin:Pin) -> Pin {
        pin.ownerId = ThisUser.instance!.id
        pin.title = titleTextField.text!
        pin.placeName = placeNameTextField.text!
//        pin.albumName = albumTextField.text!
        pin.date = dateTextField.text!.toDate()
        pin.story = storyTextView.text!
        pin.iconName = self.iconName
        pin.privacy = Privacy(rawValue: privacySegmentedControl.selectedSegmentIndex)!
        pin.image = Helper.resizeImage(image: pinImage.image!, newWidth: 400)
        
//        if albumTextField.text == "No Album Selected"{
//            pin.albumName = ""
//        }
        
        //Pin is gettings its first or new album
        if pin.albumId != selectedAlbumId{
            if let id = selectedAlbumId{
                pin.albumId = id
            }
        }
        
        return pin
    }
    
    
    func setupGestures(){
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        self.pinImage.isUserInteractionEnabled = true
        self.pinImage.addGestureRecognizer(tapImage)
        
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapView)
    }
    
    func setupStoryTextView(){
        
        storyTextView.text = "Your story..."
        storyTextView.textColor = UIColor.lightGray
        storyTextView.layer.borderColor = UIColor.gray.cgColor
        
    }
    
    func imageTapped(){
        
        presentAlerts()
    }
    
    func closeKeyBoard(){
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func selectIconButton(_ sender: UIButton) {
        performSegue(withIdentifier: String(describing: IconCollectionController.self), sender: self)
    }
    


    
    @IBAction func albumButton(_ sender: UIButton) {
        
        
        let userId = FIRAuth.auth()!.currentUser?.uid
        let albumQuery = ref.child("albums").queryOrdered(byChild: "ownerId").queryEqual(toValue: userId)
        
        //Query gets all albums belonging to this user
        albumQuery.observe(.value, with: { snapshot in
            for item in snapshot.children{
                let snap = item as! FIRDataSnapshot
                let key = snap.key
                let name = snap.value(forKey: "name") as! String
                self.albumData.append((key,name))
            }
            self.performSegue(withIdentifier: "pickAlbum", sender: self)
        })
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromBuilder" {
        
            if let mapVc = segue.destination as? MapViewController{

                
                mapVc.updatePin(pinId: pin!.id!)
                mapVc.panTo(coordinate: pin!.coordinate, mapView: mapVc.mapView)
            }
            
        }
        
        else if segue.identifier == String(describing: IconCollectionController.self){
            if let iconVc = segue.destination as? IconCollectionController{
                iconVc.iconDelegate = self
            }
        }
        
    }
    
    

    
    
    @IBAction func savePin(_ sender: UIButton) {
        
        
        if let pin = self.pin{
            let updatedPin = makePin(pin: pin)
            updatedPin.save(newAlbum: nil)
            // TODO: change to Any Object
            
        }
        
        else{
            let title = titleTextField.text
            let pinToBuild = Pin(title: title!, ownerId: self.thisUserId, coordinate: location)
            let newPin = makePin(pin:pinToBuild)
            self.pin = newPin
            newPin.save(newAlbum: nil)
        }
        
        
        performSegue(withIdentifier: "fromBuilder", sender: self)
    }
    
    
    @IBAction func unwindFromIcons(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func unwindFromSomewhere(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func unwindFromIconSelection(segue: UIStoryboardSegue){
        
        
    }
    
}


extension BuildPinViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.dateTextField {

            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dateTextField.text = datePicker.date.toString()
        textField.resignFirstResponder()
        return true
    }
    
    
    func dateChanged(sender:UIDatePicker){
        self.dateTextField.text = sender.date.toString()
        // TODO: add an invisible view to click on to escape keyboard
    }
    
    func dropTextField(){
        dateTextField.resignFirstResponder()
    }
}



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
        if !insetsExpanded{
            adjustInsetForKeyboardShow(show: true, notification: notification)
            insetsExpanded = true
        }
        
        
    }
    
    func keyboardDidShow(notification: Notification){
    }
    
    
    func keyboardWillHide(notification: Notification) {
        
        if insetsExpanded{
            adjustInsetForKeyboardShow(show: false, notification: notification)
            insetsExpanded = false
        }
    }
}


extension BuildPinViewController: UITextViewDelegate{
    
    
    // Mark: Used to create a pseudo placeholder field
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
//        let bottom = storyTextView.frame.origin.y + storyTextView.bounds.height
//        let bottomPoint = CGPoint(x:0,y:bottom)
//        scrollView.setContentOffset(bottomPoint, animated: true)
//        
        return true
    }
}


// This only exists because unwind segues are broken in this project.
extension BuildPinViewController: IconDelegate {
    
    func updateIcon(iconName: String) {
        self.iconName = iconName
        
        
        iconButton.imageView?.sd_setImage(with: FirConst.iconRef.child(iconName + "@3x.png"), placeholderImage: nil){
            
            image, error, cache, ref in
            
            self.iconButton.setImage(image, for: .normal)
        }
    }
}
