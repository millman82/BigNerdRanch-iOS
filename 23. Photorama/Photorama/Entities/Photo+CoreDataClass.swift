//
//  Photo+CoreDataClass.swift
//  Photorama
//
//  Created by Tim Miller on 8/10/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    @objc public enum CategoryType: Int16 {
        case interesting = 0
        case recent = 1
    }
}
