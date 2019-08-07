//
//  PhotoStore.swift
//  Photorama
//
//  Created by Tim Miller on 8/6/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import UIKit

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        
        let url = FlickrApi.interestingPhotosUrl
        fetchPhotoList(url, completion)
    }
    
    func fetchRecentPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        
        let url = FlickrApi.recentPhotosUrl
        fetchPhotoList(url, completion)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        let photoUrl = photo.remoteUrl
        let request = URLRequest(url: photoUrl)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                print("Respose code: \(response.statusCode)")
                
                for header in response.allHeaderFields {
                    print("Header \(header.key): \(header.value)")
                }
            }
            
            let result = self.processImageRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func fetchPhotoList(_ url: URL, _ completion: @escaping (Result<[Photo], Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                print("Respose code: \(response.statusCode)")
                
                for header in response.allHeaderFields {
                    print("Header \(header.key): \(header.value)")
                }
            }
            
            let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> Result<[Photo], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrApi.photos(fromJson: jsonData)
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> Result<UIImage, Error> {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        
        return .success(image)
    }
}
