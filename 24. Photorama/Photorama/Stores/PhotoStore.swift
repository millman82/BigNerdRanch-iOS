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
        fetchPhotoList(url, category: Photo.CategoryType.interesting, completion)
    }
    
    func fetchRecentPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        
        let url = FlickrApi.recentPhotosUrl
        fetchPhotoList(url, category: Photo.CategoryType.recent, completion)
    }
    
    func fetchAllPhotos(for category: Photo.CategoryType, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.category)) == \(category.rawValue)")
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchFavoritePhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.isFavorite)) == YES")
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let favoritePhotos = try viewContext.fetch(fetchRequest)
                completion(.success(favoritePhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func viewImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        fetchImage(for: photo) { (result) in
            if case .success = result {
                photo.viewCount += 1
                
                let context = self.persistentContainer.viewContext
                do {
                    try context.save()
                } catch {
                    print("Failed to save view count update.")
                }
            }
            
            completion(result)
        }
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
    
    func fetchAllTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func fetchPhotoList(_ url: URL, category: Photo.CategoryType, _ completion: @escaping (Result<[Photo], Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                print("Respose code: \(response.statusCode)")
                
                for header in response.allHeaderFields {
                    print("Header \(header.key): \(header.value)")
                }
            }
            
            self.processPhotosRequest(data: data, category: category, error: error) { (result) in
                
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, category: Photo.CategoryType, error: Error?, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let jsonData = data else {
            completion(.failure(error!))
            return
        }
        
        persistentContainer.performBackgroundTask { (context) in
            let result = FlickrApi.photos(fromJson: jsonData, photoCategory: category, into: context)
            
            do {
                try context.save()
            } catch {
                print("Error saving to Core Data: \(error).")
                completion(.failure(error))
                return
            }
            
            switch result {
            case let .success(photos):
                let photoIds = photos.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPhotos = photoIds.map { return viewContext.object(with: $0) } as! [Photo]
                completion(.success(viewContextPhotos))
            case .failure:
                completion(result)
            }
        }
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
