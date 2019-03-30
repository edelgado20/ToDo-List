//
//  AddItemVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class AddItemVC: UIViewController, UITextViewDelegate {
    var realm: Realm!
    var category: Category = Category()
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var itemDescripField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemDescripField.delegate = self
        
        realm = try! Realm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let item = Item()
        item.name = itemNameField.text!
        item.descrip = itemDescripField.text
        item.id += 1
        item.category = self.category
        // Get the index based on the total items count (e.g 0,1,2,3 ...)
        let predicate = NSPredicate(format: "category = %@", category)
        let count = realm.objects(Item.self).filter(predicate).count
        item.index = count
        
        // Do not add an item without a name
        if (item.name != "") {
            try! self.realm.write {
                self.realm.add(item)
            }
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        itemDescripField.text = ""
    }

}
