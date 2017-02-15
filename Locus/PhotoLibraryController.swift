//
//  PhotoLibraryController.swift
//  Locus
//
//  Created by Nabil K on 2017-02-11.
//  Copyright © 2017 MakeSchool. All rights reserved.
//


protocol KhajaPhotoLibraryDelegate: class{
    func getImagesAndMetaData(info: [(image: UIImage, metaData: [String:Any])])
}

protocol GeoTaggedLibrary: class{
    func getImagesWithGps(completion: @escaping (MetaPhotoStorage) -> ())
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
    var metaPhotoStorage: MetaPhotoStorage = MetaPhotoStorage()
    var properties = [[String:Any]]()
    var selectedImage: UIImage?
    var multiSelect: Bool = false
    var selectedIndexes: [Int:Bool] = [:]
    weak var delegate: Mappable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImagesWithGps { [unowned self] metaPhotos in
            self.metaPhotoStorage = metaPhotos
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
        
        var photoStorage = [GpsPhoto]()
        
        //return new metaPhotoStorage with only desired photos
        for key in selectedIndexes.keys {
            // Items below are guaranteed to exist at this point
            if selectedIndexes[key]! {
                
                let metaPhoto = metaPhotoStorage.metaPhotos[key]
                let gps = metaPhoto.data!["{GPS}"] as! [String:Any]
                let lat = gps["Latitude"] as! CLLocationDegrees
                let lon = gps["Longitude"] as! CLLocationDegrees
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                let gpsPhoto = GpsPhoto(image: metaPhoto.image!, location: location)
                photoStorage.append(gpsPhoto)
                
            }


        }
        
        if delegate != nil  && photoStorage.count > 0{
            delegate!.getSelectedGpsPhotos(gpsPhotos: photoStorage)
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
        
        return metaPhotoStorage.metaPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AssetCollectionCell.self), for: indexPath) as! AssetCollectionCell
        
        let row = indexPath.row
        
        let metaPhotos = metaPhotoStorage.metaPhotos
        
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
        
        
        cell.imageView.image = metaPhotos[row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let metaPhotos = metaPhotoStorage.metaPhotos
        if let gps = metaPhotos[indexPath.row].data!["{GPS}"] as? [String:Any]{
            if let longitude = gps["Longitude"] as? Double{
                print(longitude)
            }
        }
        
        let row = indexPath.row
        selectedImage = metaPhotoStorage.metaPhotos[row].image
        
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
    
    func hasCoordinates(image:CIImage) -> Bool{
        var hasLongitude = false
        var hasLatitude = false
        
        let properties = image.properties
        if let gps = properties["{GPS}"] as? [String:Any]{
            if (gps["Longitude"] as? Double) != nil{
                hasLongitude = true
            }
            if (gps["Latitude"] as? Double) != nil{
                hasLatitude = true
            }
        }
        
        return hasLatitude && hasLongitude
    }
    
    // Its a waste to make the image just for meta-data, find a better way
    func makeImage(contentEditingInput: PHContentEditingInput?) -> CIImage?{
        if let url = contentEditingInput?.fullSizeImageURL{
            let fullImage = CIImage(contentsOf: url)
            if let fullImage = fullImage{
                return fullImage
            }
        }
        return nil
    }
    
    
    func fetchPhotos(imgManager: PHImageManager, fetchResult: PHFetchResult<PHAsset>, requestOptions: PHImageRequestOptions, completion: @escaping (MetaPhotoStorage) -> ()){
        
        var output = MetaPhotoStorage()
        var output_dispatch = DispatchGroup()
        

        
        //Options for retrieving meta data
        let editingOtions = PHContentEditingInputRequestOptions()
        editingOtions.isNetworkAccessAllowed = true
        
        for i in 0..<fetchResult.count {
            
            
            // the photo-properties tuple for this pair if there are GPS coordinates available
            var thisMetaPhoto = MetaPhoto()
            
            // tells us whether this photos has GPS data
            var gpsPhotoIndex = false
            
        
            
            
            let asset = fetchResult.object(at: i)
            
            output_dispatch.enter()
            asset.requestContentEditingInput(with: editingOtions, completionHandler: { contentEditingInput, info in
                
                // Makes a CImage
                let cImage = self.makeImage(contentEditingInput: contentEditingInput)
                if let image = cImage{
                    //Checks if GPS exists using properties of CIImage
                    if self.hasCoordinates(image: image){
                        thisMetaPhoto.data = image.properties
                        gpsPhotoIndex = true
                    }
                }
                
                if gpsPhotoIndex{
                    
                    // desired size of returned images
                    let size = CGSize(width: 200, height: 200)
                    
                    // Only returning photos with image data, Request the image of given quality sychronously
                    imgManager.requestImage(for: asset,
                                            targetSize: size,
                                            contentMode: .aspectFit,
                                            options: requestOptions,
                                            resultHandler: { image, info in
                                               thisMetaPhoto.image = image
                                                output.storePhoto(metaPhoto: thisMetaPhoto)
                    })
                }
                
                output_dispatch.leave()
            })
        }
        
        output_dispatch.notify(queue: DispatchQueue.main) { 
            completion(output)
        }
        

    }
    
    
    func getImagesWithGps(completion: @escaping (MetaPhotoStorage) -> ()){
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
             fetchPhotos(imgManager: imgManager, fetchResult: fetchResult, requestOptions: requestOptions, completion: { metaPhotos in
                completion(metaPhotos)
             })
        }
        
        else{
            return
        }
    }
}



        
struct MetaPhotoStorage{
    var metaPhotos = [MetaPhoto]()
    
    mutating func storePhoto(metaPhoto: MetaPhoto){
        if let image = metaPhoto.image, let meta = metaPhoto.data{
            let metaPhoto = MetaPhoto(image: image, data: meta)
            metaPhotos.append(metaPhoto)
        }
    }
}

struct MetaPhoto {
    var image: UIImage?
    var data: [String:Any]?
}


// refactor metaPhotos to GPS photos time permitting
struct GpsPhoto{
    var image: UIImage
    var location: CLLocationCoordinate2D
}
