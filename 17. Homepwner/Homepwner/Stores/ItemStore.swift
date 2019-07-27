//
//  ItemStore.swift
//  Homepwner
//
//  Created by Tim Miller on 7/20/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemStore {
    
    var allItems = [Item]()
    let itemArchiveURL: URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent("items.archive")
    }()
    
    @discardableResult func createItem() -> Item {
        let newItem = Item(random: true)
        
        allItems.append(newItem)
        
        return newItem
    }
    
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // Get reference to object being moved so you can reinsert it
        let movedItem = allItems[fromIndex]
        
        // Remove item from array
        allItems.remove(at: fromIndex)
        
        // Insert item in array at new location
        allItems.insert(movedItem, at: toIndex)
    }
    
    func removeItem(_ item: Item) {
        if let index = allItems.firstIndex(of: item) {
            allItems.remove(at: index)
        }
    }
    
    func saveChanges() -> Bool {
        do {
            print("Saving items to: \(itemArchiveURL.path)")
            let data = try PropertyListEncoder().encode(allItems)
            try data.write(to: itemArchiveURL)
            return true
        } catch {
            print("Failed to save items")
            return false
        }
    }
    
    init() {
        let data = try? Data(contentsOf: itemArchiveURL)
        
        do {
            if let data = data {
                let archivedItems = try PropertyListDecoder().decode([Item].self, from: data)
                allItems = archivedItems
                print("Loaded archived items")
            }
        } catch {
            print("Loading archive file failed \(error)")
            
            if let data = data {
                // This may have been encoded the legacy way
                do {
                    if let archivedItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Item] {
                        allItems = archivedItems
                        print("Loaded items from legacy archive")
                    }
                } catch {
                    print("Archive file corrupt \(error)")
                }
            }
        }
    }
}
