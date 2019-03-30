//
//  Item.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var id: Int = Int.random(in: (Int.min...Int.max))
    @objc dynamic var name: String = ""
    @objc dynamic var descrip: String = ""
    @objc dynamic var category: Category?
    @objc dynamic var completed: Bool = false
    // index is used to sort the objects by its index to support drag and drop of tableview cells
    @objc dynamic var index: Int = .max
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
