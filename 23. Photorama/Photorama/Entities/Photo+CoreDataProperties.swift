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

    @NSManaged public var category: CategoryType
    @NSManaged public var dateTaken: Date?
    @NSManaged public var photoId: String?
    @NSManaged public var remoteUrl: NSURL?
    @NSManaged public var title: String?
    @NSManaged public var viewCount: Int64
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Photo {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
