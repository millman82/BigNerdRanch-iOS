//
//  ItemStore.swift
//  Homepwner
//
//  Created by Tim Miller on 7/20/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemStore {
    
    var allItems = [Item]() {
        didSet {
            applyGrouping()
        }
    }
    
    var itemsOver50 = [Item]()
    var otherItems = [Item]()
    
    func applyGrouping() {
        itemsOver50 = self.allItems.filter { (item) -> Bool in
            return item.valueInDollars > 50
        }
        
        otherItems = self.allItems.filter({ (item) -> Bool in
            return item.valueInDollars <= 50
        })
    }
    
    @discardableResult func createItem() -> Item {
        let newItem = Item(random: true)
        
        allItems.append(newItem)
        
        return newItem
    }
    
    init() {
        for _ in 0..<5 {
            createItem()
        }
    }
}
