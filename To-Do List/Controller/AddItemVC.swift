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
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let item = Item()
        item.name = itemNameField.text!
        item.descrip = itemDescripField.text
        item.id += 1
        item.category = self.category
        
        try! self.realm.write {
            self.realm.add(item)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        itemDescripField.text = ""
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
