//
//  DateView.swift
//  Locus
//
//  Created by Nabil K on 2017-01-13.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

protocol dateViewDelegate {
    func getSelectedDate()
}

class DateView: UIView {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func pickDateButton(_ sender: Any) {
        
        
    }

}
