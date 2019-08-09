//
//  PhotoItem.swift
//  Photorama
//
//  Created by Tim Miller on 8/6/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import Foundation

class FlickrPhoto: Decodable {
    let title: String
    let remoteUrl: URL?
    let photoId: String
    let dateTaken: Date
    
    enum CodingKeys: String, CodingKey {
        case title
        case remoteUrl = "url_h"
        case photoId = "id"
        case dateTaken = "datetaken"
    }
}
