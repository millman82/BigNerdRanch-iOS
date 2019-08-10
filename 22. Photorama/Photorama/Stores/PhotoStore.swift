//
//  PhotoStore.swift
//  Photorama
//
//  Created by Tim Miller on 8/6/19.
//  Copyright © 2019 Tim Miller. All rights reserved.
//

import CoreData
import UIKit 

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    
    let imageStore: ImageStore
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
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
        
        guard let photoKey = photo.photoId else {
            preconditionFailure("Photo expected to have a photoId.")
        }
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard let photoUrl = photo.remoteUrl else {
            preconditionFailure("Photo expected to have a remote URL.")
        }
        let request = URLRequest(url: photoUrl as URL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                print("Respose code: \(response.statusCode)")
                
                for header in response.allHeaderFields {
                    print("Header \(header.key): \(header.value)")
                }
            }
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
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
            
            var result = self.processPhotosRequest(data: data, error: error)
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            
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
        
        return FlickrApi.photos(fromJson: jsonData, into: persistentContainer.viewContext)
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
    
    init(imageStore: ImageStore) {
        self.imageStore = imageStore
    }
}
