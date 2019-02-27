//
//  Edit_Item_VC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/12/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class Edit_Item_VC: UIViewController {
    var realm: Realm? = nil
    
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editDescription: UITextView!
    @IBOutlet weak var saveItemButton: UIBarButtonItem!
    
    var getItem = Item()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit \(getItem.name)"
        realm = try! Realm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editName.text = getItem.name
        editDescription.text = getItem.descrip
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveEditItem(_ sender: Any) {
        try! self.realm?.write {
            getItem.name = editName.text ?? ""
            getItem.descrip = editDescription.text
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func itemNameTextField(_ sender: Any) {
        saveItemButton.isEnabled = editName.text != ""
    }
    
}