//
//  DateController.swift
//  Locus
//
//  Created by Nabil K on 2017-01-14.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import UIKit

class DateController: UIViewController {
    
    var selectedDate: Date = Date()

    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.date = selectedDate

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitButton(_ sender: UIButton) {
        selectedDate = datePicker.date
        performSegue(withIdentifier: "unwindFromDate", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromDate"{
            if let build = segue.destination as? BuildPinViewController{
                build.dateLabel.text! = selectedDate.toString()
            }
        }
    }
    

    


}
