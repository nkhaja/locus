//
//  PhotoLibraryController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-11.
//  Copyright © 2017 MakeSchool. All rights reserved.
//


protocol GeoTaggedLibrary: class{
    
//    func getImagesWithGps(completion: @escaping ([GpsPhoto]) -> ())
    var imgManager: PHImageManager? {get set}
    var requestOptions: PHImageRequestOptions? {get set}
    var fetchResult: PHFetchResult<PHAsset>? {get set}
    
    func getImageWithGps(index: Int, completion: @escaping (GpsPhoto) -> ())
}

protocol Mappable: class {
    func getSelectedGpsPhotos(gpsPhotos: [GpsPhoto])
//    func getselectedGpsPhoto(gpsPhoto: GpsPhoto)
}



import UIKit
import Photos
import SDWebImage

class PhotoLibraryController: UIViewController, GeoTaggedLibrary {
    
    
    internal var imgManager: PHImageManager?
    internal var requestOptions: PHImageRequestOptions?
    internal var fetchResult: PHFetchResult<PHAsset>?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!
    
    

    var selectedImage: UIImage?
    var multiSelect: Bool = false
    var selectedIndexes: [Int:Bool] = [:]
    var selectedPhotos = [GpsPhoto]()
    var numPhotos: Int = 0
    weak var delegate: Mappable?
    
    //Photo Library Vars
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFetchResult()
        submitButton.isHidden = true
        submitButton.layer.cornerRadius = 8
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
//        
//        for (key, value) in selectedIndexes {
//            if value{
//                photosToSend.append(self.gpsPhotos[key])
//            }
//        }
//        
//        if delegate != nil  && gpsPhotos.count > 0{
//            delegate!.getSelectedGpsPhotos(gpsPhotos: photosToSend)
//        }
        
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
        
        return fetchResult!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AssetCollectionCell.self), for: indexPath) as! AssetCollectionCell
        
        let row = indexPath.row
        
        getImageWithGps(index: indexPath.row) { photo in
            
            cell.imageView.image = photo.image
            
        }
        
        
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
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let cell = collectionView.cellForItem(at: indexPath) as! AssetCollectionCell
        
        selectedImage = cell.imageView.image
        
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
    
    func getFetchResult(){
        
        self.imgManager = PHImageManager.default()
        
        // Requestion options determine media type, and quality
        self.requestOptions = PHImageRequestOptions()
        requestOptions!.isSynchronous = false
        requestOptions!.deliveryMode = .highQualityFormat
        requestOptions!.isNetworkAccessAllowed = true
        
        // Options for retrieving photos
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
    }


    // Mark: Getting a single Photo
    func fetchPhoto(imgManager: PHImageManager, fetchResult: PHFetchResult<PHAsset>, requestOptions: PHImageRequestOptions, index: Int, completion: @escaping (GpsPhoto) -> ()){
        
        
        let editingOtions = PHContentEditingInputRequestOptions()
        editingOtions.isNetworkAccessAllowed = true
        
        let size = CGSize(width: 500, height: 500)
        
        let asset = fetchResult.object(at: index)
                
        
        imgManager.requestImage(for: asset,
                                targetSize: size,
                                contentMode: .aspectFit,
                                options: requestOptions,
                                resultHandler: { image, info in
                                    if let coordinate = asset.location?.coordinate, let image = image{
                                        let location2d = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                        
                                        let gpsPhoto = GpsPhoto(image: image, location: location2d)
                                        
                                        completion(gpsPhoto)
                                        
                                    }
                                    
                        
        })
    }
    
        
        func getImageWithGps(index: Int, completion: @escaping (GpsPhoto) -> ()) {
        
            if fetchResult!.count > 0 {
                
                fetchPhoto(imgManager: imgManager!, fetchResult: fetchResult!, requestOptions: requestOptions!, index: index, completion: { gpsPhoto in
                    
                    completion(gpsPhoto)
                    
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
        
        init(image: UIImage, location: CLLocationCoordinate2D){
            
            self.image = image
            self.location = location
        }
}

