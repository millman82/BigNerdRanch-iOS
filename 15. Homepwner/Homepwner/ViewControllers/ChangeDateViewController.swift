//
//  ChangeDateViewController.swift
//  Homepwner
//
//  Created by Tim Miller on 7/25/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

protocol ChangeDateDelegate {
    func dateChanged(_ date: Date)
}

class ChangeDateViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    
    var date: Date?
    var delegate: ChangeDateDelegate!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Select Date"
        
        if let date = date {
            datePicker.date = date
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if date != datePicker.date {
            delegate.dateChanged(datePicker.date)
        }
    }
}
