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
    @objc dynamic var dueDate: String = ""
    
    // index is used to sort the objects by its index to support drag and drop of tableview cells
    @objc dynamic var index: Int = .max
    // images are converted to strings which are URL's (The entire images are saved in the documents file sevice)
    let imageNames = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
