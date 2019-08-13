//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Tim Miller on 8/7/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var photoDescription: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
    override var accessibilityLabel: String? {
        get {
            return photoDescription
        }
        set {
            // Ignore attempts to set
        }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            var traits = super.accessibilityTraits
            traits.insert(UIAccessibilityTraits.image)
            return traits
        }
        set {
            // Ignore attempts to set
        }
    }
    
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
}
