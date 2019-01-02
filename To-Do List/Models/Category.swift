//
//  Category.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var id: String = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
