//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Tim Miller on 8/7/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var viewCount: UILabel!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.viewImage(for: photo) { (result) in
            switch result {
            case let .success(image):
                self.imageView.image = image
                self.viewCount.text = "Views: \(self.photo.viewCount)"
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}
