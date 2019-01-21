//
//  Item.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import Foundation
import RealmSwift

//struct ItemContainer: Codable {
//    let status: String
//    let content: [Item]
//}

class Item: Object {
    
    @objc dynamic var id: Int = Int(arc4random_uniform(100) + 1)
    @objc dynamic var name: String = ""
    @objc dynamic var descrip: String = ""
    @objc dynamic var category: Category?
    @objc dynamic var categoryID: String?
    @objc dynamic var completed: Bool = false
    
//    enum RootKeys: String, CodingKey {
//        case status
//        case content
//    }

//    enum ContentKeys: String, CodingKey {
//        case id
//        case name
//        case descrip = "description"
//        case categoryID = "category_id"
//        case completed
//    }

//    required convenience init(from decoder: Decoder) throws {
//        self.init()
        //let container = try decoder.container(keyedBy: RootKeys.self)
//        var status = try container.nestedUnkeyedContainer(forKey: .status)
        
//        let container = try decoder.container(keyedBy: ContentKeys.self)
//
//        let id = try container.decode(String.self, forKey: .id)
//        let name = try container.decode(String.self, forKey: .name)
//        let descrip = try container.decode(String.self, forKey: .descrip)
//        let categoryID = try container.decode(String.self, forKey: .categoryID)
//        let completed = try container.decode(String.self, forKey: .completed)
//        print("ID: \(id)")
//        print("Name: \(name)")
//        print("Descrip: \(descrip)")
//        print("CategoryID: \(categoryID)")
//        print("Completed: \(completed)")
//    }

    //func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: .self)
//
//        var status = try container.nestedContainer(keyedBy: ContentKeys.self, forKey: .status)
//        try status.encode(id, forKey: .id)
//        try status.encode(name, forKey: .name)
//        try status.encode(descrip, forKey: .descrip)
        
        
        //try status.encode(category, forKey: .category)
    //}
}
