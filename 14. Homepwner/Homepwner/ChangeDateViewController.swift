//
//  ChangeDateViewController.swift
//  Homepwner
//
//  Created by Tim Miller on 7/25/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ChangeDateViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    
    var item: Item!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Date Created"
        
        datePicker.date = item.dateCreated
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        item.dateCreated = datePicker.date
    }
}
