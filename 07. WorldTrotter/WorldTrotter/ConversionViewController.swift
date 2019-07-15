//
//  ConversionViewController.swift
//  WorldTrotter
//
//  Created by Tim Miller on 7/13/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ConversionViewController : UIViewController {
    
    @IBOutlet var celsiusLabel: UILabel!
    @IBOutlet var isReallyLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    var fahrenheitValue: Measurement<UnitTemperature>? {
        didSet {
            updateCelsiusLabel()
        }
    }
    
    var celsiusValue: Measurement<UnitTemperature>? {
        if let fahrenheitValue = fahrenheitValue {
            return fahrenheitValue.converted(to: .celsius)
        } else {
            return nil
        }
    }
    
    var allowedCharacters = CharacterSet(charactersIn: "0123456789")
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ConversionViewController loaded its view.")
        
        updateCelsiusLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents(Set<Calendar.Component>(arrayLiteral: Calendar.Component.hour, Calendar.Component.minute), from: date)
        
        if let hour = components.hour, let minutes = components.minute {
            if hour > 21 || (hour < 6 && minutes <= 45) {
                isReallyLabel.textColor = UIColor.lightGray
                view.backgroundColor = UIColor(red: 48.0/255.0, green: 49.0/255.0, blue: 52.0/255.0, alpha: 1.0)
            } else {
                isReallyLabel.textColor = nil
                view.backgroundColor = UIColor(red: 245.0/255.0, green: 244.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            }
        }
    }
    
    @IBAction func fahrenheitFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text, let number = numberFormatter.number(from: text) {
            fahrenheitValue = Measurement(value: number.doubleValue, unit: .fahrenheit)
        } else {
            fahrenheitValue = nil
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    func updateCelsiusLabel() {
        if let celsiusValue = celsiusValue {
            celsiusLabel.text = numberFormatter.string(from: NSNumber(value: celsiusValue.value))
        } else {
            celsiusLabel.text = "???"
        }
    }
    
}

extension ConversionViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentLocale = Locale.current
        let decimalSeparator = currentLocale.decimalSeparator ?? "."
        
        allowedCharacters.insert(charactersIn: decimalSeparator)
        let components = string.components(separatedBy: allowedCharacters.inverted)
        let filtered = components.joined()
        
        if string != filtered {
            return false
        }
        
        let existingTextHasDecimalSeparator = textField.text?.range(of: decimalSeparator)
        let replacementTextHasDecimalSeparator = string.range(of: decimalSeparator)
        
        if existingTextHasDecimalSeparator != nil, replacementTextHasDecimalSeparator != nil {
            return false
        }
        
        return true
    }
    
}
