//
//  FlickrApi.swift
//  Photorama
//
//  Created by Tim Miller on 8/6/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import CoreData
import Foundation

enum FlickrError: Error {
    case invalidJSONData
}

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
}

struct FlickrApi {
    
    private static let baseUrlString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static var interestingPhotosUrl: URL {
        return flickrUrl(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    static var recentPhotosUrl: URL {
        return flickrUrl(method: .recentPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    static func photos(fromJson data: Data, photoCategory category: Photo.CategoryType, into context: NSManagedObjectContext) -> Result<[Photo], Error> {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photosJsonObject = jsonDictionary["photos"] as? [String:Any],
                let photosJsonArray = photosJsonObject["photo"] as? [[String:Any]] else {

                    // The JSON structure doesn't match our expectations
                    return .failure(FlickrError.invalidJSONData)
            }
            
            let photosData = try JSONSerialization.data(withJSONObject: photosJsonArray, options:[])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let photoItems = try decoder.decode([FlickrPhoto].self, from: photosData)
            
            if photoItems.isEmpty {
                // We weren't able to parse any of the photos
                // Maybe the JSON format for photos has changed
                return .failure(FlickrError.invalidJSONData)
            }
            
            // Only retrieving large image urls so if a large url is missing we need to filter them out
            // Then we map it to the model used for presentation
            let photos = photoItems.filter { return $0.remoteUrl != nil }
                .map { return photo(from: $0, category: category, into: context) }
            
            return .success(photos)
        }  catch let error {
            return .failure(error)
        }
    }
    
    private static func flickrUrl(method: Method, parameters: [String:String]?) -> URL {
        
        var components = URLComponents(string: baseUrlString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    private static func photo(from flickrPhoto: FlickrPhoto, category: Photo.CategoryType, into context: NSManagedObjectContext) -> Photo {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.photoId)) == \(flickrPhoto.photoId) AND \(#keyPath(Photo.category)) == \(category.rawValue)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]?
        context.performAndWait {
            fetchedPhotos = try? fetchRequest.execute()
        }
        if let existingPhoto = fetchedPhotos?.first {
            return existingPhoto
        }
        
        var photo: Photo!
        context.performAndWait {
            photo = Photo(context: context)
            photo.title = flickrPhoto.title
            photo.photoId = flickrPhoto.photoId
            photo.remoteUrl = flickrPhoto.remoteUrl as NSURL?
            photo.dateTaken = flickrPhoto.dateTaken
            photo.category = category
        }
        
        return photo
    }
}
