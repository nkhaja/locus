//
//  Helper.swift
//  Locus
//
//  Created by Nabil K on 2017-01-12.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class Helper{
    

    
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
