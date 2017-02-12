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
    var placeName: String?
    var location: CLLocationCoordinate2D!
    var thisUserId:String = FIRAuth.auth()!.currentUser!.uid
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var iconName: String = "redGooglePin"
    
    // Vars for pickerView transitions
    var albumData: [(String, String)] = []
    var selectedAlbumId: String?

    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
//    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var albumTextField: UITextField!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var iconButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup
        setupKeyboard()
        setupGestures()
        
        
        //Set datePicker as Input for dateTextfield
        dateTextField.delegate = self
        
        
        
        //Setup if pre-existing pin
        if let pin = self.pin{
            self.pinImage.image = pin.image!
            let thisIcon = UIImage(named: pin.iconName)
            self.iconButton.setImage(thisIcon, for: .normal)
            
            self.titleTextField.text! = pin.title
            self.placeNameTextField.text! = pin.placeName
            self.dateTextField.text! = pin.date.toString()
            self.albumTextField.text! = pin.albumName
            self.storyTextView.text! = pin.story
            self.placeName = pin.placeName
            self.iconName = pin.iconName
            
        }
        
        //Setup if new pin
        else{
            self.iconButton.setImage(#imageLiteral(resourceName: "redGooglePin"), for: .normal)
            placeNameTextField.text! = self.placeName!
            dateTextField.text! = Date().toString()
            albumTextField.text! = "No Album Selected"
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
        pin.title = titleTextField.text!
        pin.placeName = placeNameTextField.text!
        pin.albumName = albumTextField.text!
        pin.date = dateTextField.text!.toDate()
        pin.story = storyTextView.text!
        pin.iconName = self.iconName
        pin.image = pinImage.image
        
        if albumTextField.text == "No Album Selected"{
            pin.albumName = ""
        }
        
        //Pin is gettings its first or new album
        if pin.albumId != selectedAlbumId{
            if let id = selectedAlbumId{
                pin.albumId = id
            }
        }
        
        return pin
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickDate" {
            if let pickDate = segue.destination as? DateController{
                
                if let pin = pin{
                    pickDate.datePicker.date = pin.date
                    pickDate.selectedDate = pin.date
                }
                
                else{
                    pickDate.selectedDate = Date()
                }
            }
            
            else if let pickAlbum = segue.destination as? AlbumController{
                if let pin = pin{
                    pickAlbum.selectedAlbumId = pin.albumId
                    pickAlbum.selectedAlbumName = pin.albumName
                }
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
            newPin.save(newAlbum: nil)
        }
    }
    
    
    
    @IBAction func unwindFromIconSelection(segue: UIStoryboardSegue){
        
    }
    

    @IBAction func unwindFromAlbum(segue:UIStoryboardSegue) {
        
    }
}


//Handle keyboard

//Extension for accessing camera with gestures

extension BuildPinViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    func setupGestures(){
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
//        let tapScreen = UITapGestureRecognizer
        self.pinImage.isUserInteractionEnabled = true
        self.pinImage.addGestureRecognizer(tapImage)
        
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapView)
    }
    
    func closeKeyBoard(){
        self.view.endEditing(true)
    }
    
    
    //Present media picking options
    func imageTapped() {
        let cameraAlert = UIAlertController(title: "Select a source", message: "Where would you like to get your photos from?", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            self.openMedia(source: .camera)
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { action in
            self.openMedia(source: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        cameraAlert.addAction(cameraAction)
        cameraAlert.addAction(galleryAction)
        cameraAlert.addAction(cancelAction)
        
        self.present(cameraAlert, animated: true, completion: nil)
    }
    
    //Open either camera or gallery
    func openMedia(source: UIImagePickerControllerSourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func requestSavingToGallery(image:UIImage?){
        let saveAlert = UIAlertController(title: "Save this image?", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            if let image = image{
                self.saveToGallery(image: image)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        saveAlert.addAction(saveAction)
        saveAlert.addAction(cancel)
        
        if image != nil{
            present(saveAlert, animated: true, completion: nil)
        }
    }
    
    
    
    //TODO: PICK UP HERE
    func saveToGallery(image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let alert = UIAlertController(title: "Save Completion",
                                      message: "Your Image has been saved to Photo Library!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    

        
        
    
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            if let image =  info[UIImagePickerControllerOriginalImage] as? UIImage{
                self.pinImage.image = image
                if picker.sourceType == .camera{
                    self.requestSavingToGallery(image: image)
                }
            }
        }
    }
    
}

extension BuildPinViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.dateTextField {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            textField.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        }
    }
    
    
    func dateChanged(sender:UIDatePicker){
        self.dateTextField.text = sender.date.toString()
        // TODO: add an invisible view to click on to escape keyboard
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
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification: Notification) {
        adjustInsetForKeyboardShow(show: false, notification: notification)
    }
}

