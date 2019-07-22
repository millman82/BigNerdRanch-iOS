//
//  ItemCell.swift
//  Homepwner
//
//  Created by Tim Miller on 7/21/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var serialNumberLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateValueLabelTextColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.adjustsFontForContentSizeCategory = true
        serialNumberLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontForContentSizeCategory = true
    }
    
    func updateValueLabelTextColor() {
        
        if let text = valueLabel.text {
            
            let index = text.index(text.startIndex, offsetBy: 1)
            if let value = Double(text[index...]) {
                
                if value < 50 {
                    valueLabel.textColor = UIColor.green
                } else {
                    valueLabel.textColor = UIColor.red
                }
            }
        }
    }
}
