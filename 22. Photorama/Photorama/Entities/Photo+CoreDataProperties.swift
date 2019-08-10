//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Tim Miller on 8/10/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photoId: String?
    @NSManaged public var title: String?
    @NSManaged public var dateTaken: Date?
    @NSManaged public var remoteUrl: NSURL?

}
