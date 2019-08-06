//
//  Photo.swift
//  Photorama
//
//  Created by Tim Miller on 8/6/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import Foundation

class Photo {
    let title: String
    let remoteUrl: URL
    let photoId: String
    let dateTaken: Date
    
    init(title: String, photoId: String, remoteUrl: URL, dateTaken: Date) {
        self.title = title
        self.photoId = photoId
        self.remoteUrl = remoteUrl
        self.dateTaken = dateTaken
    }
}
