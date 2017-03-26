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
    
    func getImageWithGps(index: Int, completion: @escaping (GpsPhoto?) -> ())
}

protocol Mappable: class {
    func getSelectedGpsPhotos(gpsPhotos: [GpsPhoto])
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
    var photosForBatch = [GpsPhoto]()

    
    weak var delegate: Mappable?
    
    // pagination
    
    var page: Int = 1
    var pageSize: Int = 25
    var lastPage: Int = 0
    var resultsFetched : Bool = false
    
    
    //Photo Library Vars
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFetchResult()
        paginate(higherIndex: true, lastPage: lastPage)
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
        
        
        let group = DispatchGroup()
        
        
        for (key, value) in selectedIndexes {
            if value{
                
                group.enter()
                getImageWithGps(index: key, completion: { photo in
                    
                    if let photo = photo{
                        photosToSend.append(photo)
                    }
                    
                    
                    
                    group.leave()
                    
                })
            
            
            }
        }
        
        
        group.notify(queue: .main, execute: {
            
            if self.delegate != nil && photosToSend.count > 0{
                self.delegate?.getSelectedGpsPhotos(gpsPhotos: photosToSend)
            }
            
            self.navigationController?.popViewController(animated: true)
            
        })
        
    }
    
    func paginate(higherIndex: Bool, lastPage: Int){
        
        var batchResult = [GpsPhoto]()
        
        var start: Int = 0
        var end: Int = 0
        var fetchCount = fetchResult!.count
        
        let group = DispatchGroup()
        
        // max fetch is less than total photos
        
        if (higherIndex && lastPage == fetchCount) || (!higherIndex && lastPage == 0){
            return
        }
        
        
        if fetchCount < pageSize {
            
            start = 0
            end = fetchCount
            self.lastPage = fetchCount
            
        }
        
        else if higherIndex {
            
            start = lastPage
            end = start + pageSize
            if end > fetchCount{
                end = fetchCount
            }
 
        }
        
        // !higherIndex
        else{
            
            end = lastPage - pageSize
            start = end - pageSize
            
            if start < 0 {
                start = 0
                end = pageSize
            }
            
        }
        

        for i in start...end {
            
            group.enter()
            getImageWithGps(index: i, completion: { photo in
                
                if let gpsPhoto = photo{
                    batchResult.append(gpsPhoto)
                }
                
                
                group.leave()
        
            })
            
            
        }
        
        group.notify(queue: .main) { 
            
            self.lastPage = end
            self.photosForBatch = batchResult
            self.collectionView.reloadData()
            
        }
        
        
        
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
        
        return photosForBatch.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AssetCollectionCell.self), for: indexPath) as! AssetCollectionCell
        
        let row = indexPath.row
        
        cell.imageView.image = photosForBatch[row].image
        
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        var row = indexPath.row
        
        if row == 0{
            return
        }
        
        if row == lastPage - 5 {
            paginate(higherIndex: true, lastPage: lastPage)
        }
        
        else if row == lastPage - 20 {
            paginate(higherIndex: false, lastPage: lastPage)
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
    func fetchPhoto(imgManager: PHImageManager, fetchResult: PHFetchResult<PHAsset>, requestOptions: PHImageRequestOptions, index: Int, completion: @escaping (GpsPhoto?) -> ()){
        
        
        let editingOtions = PHContentEditingInputRequestOptions()
        editingOtions.isNetworkAccessAllowed = true
        
        let size = CGSize(width: 300, height: 300)
        
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
                                    
                                    else {completion(nil)}
                                    
                                
                                    
                        
        })
    }
    
        // returns a GPS photo by checking the given index in the fetch result
        func getImageWithGps(index: Int, completion: @escaping (GpsPhoto?) -> ()) {
        
            if fetchResult!.count > 0 && fetchResult!.count > index {
                
                fetchPhoto(imgManager: imgManager!, fetchResult: fetchResult!, requestOptions: requestOptions!, index: index, completion: { gpsPhoto in
                    
                    completion(gpsPhoto)
                    
                })

            }
                
            else{
                completion(nil)
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

