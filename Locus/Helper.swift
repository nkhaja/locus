//
//  Helper.swift
//  Locus
//
//  Created by Nabil K on 2017-01-12.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Helper {
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return newImage!
    }
    
    
    static func instantiateController(storyboardName: String, controllerName: String, bundle: Bundle?) -> UIViewController{
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardName)
        
        return vc
    }
    
    
    
}


protocol Clearable {
    
    // meant to clear non-custom annotations (i.e. pins used to sample locations)
    func clearAnnotations()
}

extension Clearable where Self: MKMapView {
    
    // TODO: Find a less than n times solution to this problem, do for single pin removal
    
    func clearAnnotations(){
        for a in self.annotations{
            let la = a as? LocusPointAnnotation
            if let la = la{
                if !la.custom {
                    self.removeAnnotation(la)
                }
            }
        }
        
    }
}


extension Date{
    func toString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

extension String{
    func toDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.date(from: self)!
        return date
    }
}

extension UIImage {
    func toData() -> Data{
        return UIImagePNGRepresentation(self)!
    }
    
}


extension Data{
    func toImage() -> UIImage{
        return UIImage(data: self)!
    }
    
}



