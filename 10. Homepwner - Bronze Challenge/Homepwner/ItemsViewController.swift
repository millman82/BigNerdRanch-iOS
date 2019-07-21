//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Tim Miller on 7/19/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    var itemStore: ItemStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return itemStore.itemsOver50.count
        default:
            return itemStore.otherItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Items Over $50"
        default:
            return "Remaining Items"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the tableview
        var item: Item!
        switch indexPath.section {
        case 0:
            item = itemStore.itemsOver50[indexPath.row]
        default:
            item = itemStore.otherItems[indexPath.row]
        }
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "$\(item.valueInDollars)"
        
        return cell
    }
}
