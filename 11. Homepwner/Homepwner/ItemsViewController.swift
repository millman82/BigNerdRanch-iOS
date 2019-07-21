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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        if indexPath.row < itemStore.allItems.count {
            // Set the text on the cell with the description of the item
            // that is at the nth index of items, where n = row this cell
            // will appear in on the tableview
            let item = itemStore.allItems[indexPath.row]
            
            cell.textLabel?.text = item.name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell.detailTextLabel?.text = "$\(item.valueInDollars)"
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        } else {
            cell.textLabel?.text = "No more items!"
            cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
            cell.detailTextLabel?.text = ""
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < itemStore.allItems.count {
            return 60
        }
        
        return 44
    }
}
