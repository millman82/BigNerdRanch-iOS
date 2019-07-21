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
    
    func items50andUnder() -> [Item] {
            let items = allItems.filter { (item) -> Bool in
                return item.valueInDollars <= 50
            }
            
            return items
        }
        
        func itemsOver50() -> [Item] {
            let items = self.allItems.filter { (item) -> Bool in
                return item.valueInDollars > 50
            }
            
            return items
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
