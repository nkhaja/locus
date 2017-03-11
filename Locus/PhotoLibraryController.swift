//
//  PhotoLibraryController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-11.
//  Copyright © 2017 MakeSchool. All rights reserved.
//


protocol GeoTaggedLibrary: class{
    func getImagesWithGps(completion: @escaping ([GpsPhoto]) -> ())
}

protocol Mappable: class {
    func getSelectedGpsPhotos(gpsPhotos: [GpsPhoto])
}



import UIKit
import Photos

class PhotoLibraryController: UIViewController, GeoTaggedLibrary {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!

    
//    var images = [UIImage]()
//    var metaPhotoStorage: MetaPhotoStorage = MetaPhotoStorage()
    var gpsPhotos = [GpsPhoto]()
    var selectedImage: UIImage?
    var multiSelect: Bool = false
    var selectedIndexes: [Int:Bool] = [:]
    weak var delegate: Mappable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImagesWithGps { gpsPhotos in
            self.gpsPhotos = gpsPhotos
            self.collectionView.reloadData()
        }
        
        
        
        submitButton.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(multiSelectPressed))
    }

    
    func multiSelectPressed(){
        multiSelect = !multiSelect
        self.submitButton.isHidden = !multiSelect
        self.selectedIndexes.removeAll()
        self.collectionView.reloadData()
    }
    
    
    @IBAction func submitButton(_ sender: UIButton) {
        var photosToSend = [GpsPhoto]()
        
        for (key, value) in selectedIndexes {
            if value{
                photosToSend.append(self.gpsPhotos[key])
            }
        }
        
        if delegate != nil  && gpsPhotos.count > 0{
            delegate!.getSelectedGpsPhotos(gpsPhotos: photosToSend)
        }
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: SeeImageController.self){
            if let seeImageController = segue.destination as? SeeImageController{
                seeImageController.image = selectedImage
            }
        }
    }
    
}


extension PhotoLibraryController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return gpsPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AssetCollectionCell.self), for: indexPath) as! AssetCollectionCell
        
        let row = indexPath.row
        
        
        if multiSelect {
            cell.checkBox.isHidden = false
            cell.layer.borderWidth = 5
            
            // check to see if this box is selected
            if let selected = selectedIndexes[row]{
                if selected{
                    cell.checkBox.image = #imageLiteral(resourceName: "checkmark")
                    cell.layer.borderColor = UIColor.green.cgColor
                }
                    
                else {
                    cell.checkBox.image = nil
                    cell.layer.borderColor = UIColor.black.cgColor
                }
            }
                
            else {
                cell.checkBox.image = nil
                cell.layer.borderColor = UIColor.black.cgColor
            }
        }
            
        else{
            cell.checkBox.isHidden = true
            cell.layer.borderWidth = 0
        }
        
        
        cell.imageView.image = gpsPhotos[row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = indexPath.row
        selectedImage = gpsPhotos[row].image
        
        if multiSelect{
            //this item has been selected before
            if let selected = selectedIndexes[row]{
                if selected {
                    selectedIndexes[row] = false
                }
                else{
                    selectedIndexes[row] = true
                }
            }
                
                // this item is being selected for the first time
            else{
                selectedIndexes[row] = true
            }
            
            self.collectionView.reloadItems(at: [indexPath])
        }
            
        else{
            performSegue(withIdentifier: String(describing: SeeImageController.self), sender: self)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}




// Currenlty repeating activity with asset getting; refactor



extension GeoTaggedLibrary {
    
    func fetchPhotos(imgManager: PHImageManager, fetchResult: PHFetchResult<PHAsset>, requestOptions: PHImageRequestOptions, completion: @escaping ([GpsPhoto]) -> ()){
        
        var output = [GpsPhoto]()
        let output_dispatch = DispatchGroup()
        

        
        //Options for retrieving meta data
        let editingOtions = PHContentEditingInputRequestOptions()
        editingOtions.isNetworkAccessAllowed = true
        
        for i in 0..<fetchResult.count {

            let asset = fetchResult.object(at: i)
            output_dispatch.enter()
   
            
            // desired size of returned images
            let size = CGSize(width: 500, height: 500)
            
            // Only returning photos with image data, Request the image of given quality sychronously
            imgManager.requestImage(for: asset,
                                    targetSize: size,
                                    contentMode: .aspectFit,
                                    options: requestOptions,
                                    resultHandler: { image, info in
                                        if let coordinate = asset.location?.coordinate, let image = image{
                                            let location2d = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                            let gpsPhoto = GpsPhoto(image: image, location: location2d)
                                            output.append(gpsPhoto)

                                        }
                                        
                                        output_dispatch.leave()


            })
            
                
        
        }
        
        output_dispatch.notify(queue: DispatchQueue.main) { 
            completion(output)
        }
        

    }
    
    
    func getImagesWithGps(completion: @escaping ([GpsPhoto]) -> ()){
        // Declare a singleton of PHImangeManger class
        let imgManager = PHImageManager.default()
        
        // Requestion options determine media type, and quality
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        // Options for retrieving photos
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        
        if fetchResult.count > 0 {
             fetchPhotos(imgManager: imgManager, fetchResult: fetchResult, requestOptions: requestOptions, completion: { gpsPhotos in
                completion(gpsPhotos)
             })
        }
        
        else{
            return
        }
    }
}

// refactor metaPhotos to GPS photos time permitting
struct GpsPhoto {
    var image: UIImage
    var location: CLLocationCoordinate2D
}
