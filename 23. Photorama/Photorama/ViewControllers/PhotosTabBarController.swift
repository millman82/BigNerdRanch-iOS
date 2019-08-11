//
//  PhotosTabBarController.swift
//  Photorama
//
//  Created by Tim Miller on 8/10/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit

class PhotosTabBarController: UITabBarController {
    
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, vc) in viewControllers!.enumerated() {
            let navigationController = vc as! UINavigationController
            let photosViewController = navigationController.topViewController as! PhotosViewController
            photosViewController.store = store
            
            if i == 0 {
                photosViewController.collectionType = .recentPhotos
            } else if i == 1 {
                photosViewController.collectionType = .interestingPhotos
            } else {
                photosViewController.collectionType = .favoritePhotos
            }
        }
    }
}
