//
//  ItemDetailTextField.swift
//  Homepwner
//
//  Created by Tim Miller on 7/25/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemDetailTextField: UITextField {
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(red: 51.0/255.0, green: 120.0/255.0, blue: 246.0/255.0, alpha: 0.7).cgColor
        
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        
        return result
    }
    
}
