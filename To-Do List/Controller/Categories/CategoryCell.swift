//
//  CategoryCell.swift
//  To-Do List
//
//  Created by COFEBE, inc. on 1/30/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryCell: UITableViewCell {

    let realm = try! Realm()

    var testItems: Results<Item> {
        get {
            return realm.objects(Item.self)
        }
    }

    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var numOfItemsLabel: UILabel!

    func setCategoryCell(category: Category) {
        // query to realm to get the count of undone items in each category
        var numberOfItems: Results<Item>? {
            get {
                let predicate = NSPredicate(format: "category = %@ AND completed = false", category)
                return realm.objects(Item.self).filter(predicate)
            }
        }
        let count = numberOfItems?.count ?? 0
        if count == 0 {
            numOfItemsLabel.text = ""
        } else {
            numOfItemsLabel.text = String(count)
        }
        categoryNameLabel.text = category.name
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    

}
