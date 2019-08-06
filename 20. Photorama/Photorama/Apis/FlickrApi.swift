//
//  FlickrApi.swift
//  Photorama
//
//  Created by Tim Miller on 8/6/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

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
    
    static func photos(fromJson data: Data) -> PhotosResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]] else {
                    
                    // The JSON structure doesn't match our expectations
                    return .failure(FlickrError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            for photoJson in photosArray {
                if let photo = photo(fromJson: photoJson) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                // We weren't able to parse any of the photos
                // Maybe the JSON format for photos has changed
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
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
    
    private static func photo(fromJson json: [String : Any]) -> Photo? {
        guard
            let photoId = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoUrlString = json["url_h"] as? String,
            let url = URL(string: photoUrlString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                
                // Don't have enough information to construct a Photo
                return nil
        }
        
        return Photo(title: title, photoId: photoId, remoteUrl: url, dateTaken: dateTaken)
    }
}
