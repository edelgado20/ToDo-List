//
//  Item.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import Foundation
import RealmSwift

class Item:Object {
    
    @objc dynamic var id: Int = Int(arc4random_uniform(100) + 1)
    @objc dynamic var name: String = ""
    @objc dynamic var descrip: String = ""
    
//    @objc dynamic var c_id: Int = 0
//    @objc dynamic var dueDate: Date
//    @objc dynamic var int: Int = 0
    
    
    
}
