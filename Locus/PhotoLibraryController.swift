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

protocol mappable {
    func getImagesWithGps()
}



import UIKit
import Photos

class PhotoLibraryController: UIViewController, mappable {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!

    
    var images = [UIImage]()
    var metaPhotoStorage: MetaPhotoStorage!
    var contentImages = [CIImage]()
    var properties = [[String:Any]]()
    var selectedImage: UIImage?
    var multiSelect: Bool = false
    var selectedIndexes: [Int:Bool] = [:]
    weak var delegate: KhajaPhotoLibraryDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.metaPhotoStorage = getImagesWithGps()
        submitButton.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(multiSelectPressed))
    }
    
    
    func retrievePhotos(){
        //Declare a singleton of PHImangeManger class
        let imgManager = PHImageManager.default()
        
        //requestion options determine media type, and quality
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResult.count > 0{
            let size = CGSize(width: 200, height: 200)
            for i in 0..<fetchResult.count {
                imgManager.requestImage(for: fetchResult.object(at: i),
                                        targetSize: size,
                                        contentMode: .aspectFit,
                                        options: requestOptions,
                                        resultHandler: { image, info in
                                            
                                            self.images.append(image!)
                })
                
                let asset = fetchResult.object(at: i)
                let options = PHContentEditingInputRequestOptions()
                options.isNetworkAccessAllowed = true
                asset.requestContentEditingInput(with: options, completionHandler: { contentEditingInput, info in
                    
                    
                    let fullImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)
                    self.properties.append(fullImage!.properties)
                    print(fullImage!.properties)
                })
                
            }
        }
            
        else{
            print("no images found")
        }
    }
    
    func multiSelectPressed(){
        multiSelect = !multiSelect
        self.submitButton.isHidden = !multiSelect
        self.selectedIndexes.removeAll()
        self.collectionView.reloadData()
    }
    
    
    @IBAction func submitButton(_ sender: UIButton) {
        
        var info = [(image: UIImage, metaData: [String:Any])]()
        for key in selectedIndexes.keys {
            info.append((images[key], properties[key]))
        }
        
        print(info.count)
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
        
        return images.count
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
        
        
        cell.imageView.image = images[row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let gps = properties[indexPath.row]["{GPS}"] as? [String:Any]{
            if let longitude = gps["Longitude"] as? Double{
                print(longitude)
            }
        }
        
        let row = indexPath.row
        selectedImage = images[row]
        
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

extension mappable {
    
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
    
    
    func fetchPhotos(imgManager: PHImageManager, fetchResult: PHFetchResult<PHAsset>, requestOptions: PHImageRequestOptions) -> MetaPhotoStorage{
        
        var output = MetaPhotoStorage()

        
        //Options for retrieving meta data
        let editingOtions = PHContentEditingInputRequestOptions()
        editingOtions.isNetworkAccessAllowed = true
        
        for i in 0..<fetchResult.count {
            
            
            // the photo-properties tuple for this pair if there are GPS coordinates available
            var thisMetaPhoto = MetaPhoto()
            
            // tells us whether this photos has GPS data
            var gpsPhotoIndex = false
            
        
            
            
            let asset = fetchResult.object(at: i)
            asset.requestContentEditingInput(with: editingOtions, completionHandler: { contentEditingInput, info in
                
                // Makes a CImage
                if let image = self.makeImage(contentEditingInput: contentEditingInput){
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
            })
        }
        
        return output
    }
    
    
    func getImagesWithGps() -> MetaPhotoStorage? {
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
            return fetchPhotos(imgManager: imgManager, fetchResult: fetchResult, requestOptions: requestOptions)
        }
        
        else{
            return nil
        }
    }
}



        
struct MetaPhotoStorage{
    var metaPhotos : [(image: UIImage, meta: [String:Any])] = []
    
    mutating func storePhoto(metaPhoto: MetaPhoto){
        if let image = metaPhoto.image, let meta = metaPhoto.data{
            let pair = (image: image, meta: meta)
            metaPhotos.append(pair)
        }
    }
}

struct MetaPhoto {
    var image: UIImage?
    var data: [String:Any]?
    
    
}
