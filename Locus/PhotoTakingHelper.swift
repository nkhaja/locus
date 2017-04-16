//
//  PhotoTakingHelper.swift
//
//
//  Created by Nabil K on 2017-03-10.
//
//

import UIKit
import MapKit


extension BuildPinViewController: PhotoTaking {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            if let image =  info[UIImagePickerControllerOriginalImage] as? UIImage{
                self.pinImage.image = image
                let metaData = info[UIImagePickerControllerMediaMetadata]
                print(metaData)
                
                
                if picker.sourceType == .camera{
                    self.requestSavingToGallery(image: image)
                }
            }
        }
    }
}


extension MapViewController: PhotoTaking{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        // TODO: This function should only run if location services are enabled
        
        picker.dismiss(animated: true) {
            
            if let image =  info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                
                let newPin = Pin(ownerId: ThisUser.instance!.id, coordinate: self.currentPosition!.coordinate, image: image)
                
                
                newPin.image = image
                newPin.save(newAlbum: nil)
                
                let metaData = info[UIImagePickerControllerMediaMetadata]
                print(metaData)
                
                
                if picker.sourceType == .camera{
                    self.requestSavingToGallery(image: image)
                }
                
                
            }
        }
        
    }
    
    
}



protocol PhotoTaking: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentAlerts()
    
    func openMedia(source: UIImagePickerControllerSourceType)
    
    func requestSavingToGallery(image:UIImage?)
    
    func saveToGallery(image:UIImage)
    
}


extension PhotoTaking where Self: UIViewController {
    
    func presentAlerts(){
        
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
    
    
    func saveToGallery(image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let alert = UIAlertController(title: "Save Completion",
                                      message: "Your Image has been saved to Photo Library!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

