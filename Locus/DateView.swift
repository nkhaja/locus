//
//  DateView.swift
//  Locus
//
//  Created by Nabil K on 2017-01-13.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

protocol DateViewDelegate {
    func getSelectedDate(date:Date)
}

class DateView: UIView {
    
    var selectedDate: Date = Date()
    var delegate: DateViewDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.datePicker.date = Date()
        self.selectedDate = Date()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func pickDateButton(_ sender: Any) {
    }
    
    
    @IBAction func submitButton(_ sender: UIButton) {
        self.selectedDate = datePicker.date
        if let delegate = delegate{
            delegate.getSelectedDate(date: selectedDate)
        }
    }
    

}
