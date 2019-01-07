//
//  EditCategoryVC.swift
//  To-Do List
//
//  Created by COFEBE, inc. on 1/3/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class EditCategoryVC: UIViewController {
    @IBOutlet weak var editCategoryField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var getCategory = Category()
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editCategoryField.text = getCategory.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func categoryTextField(_ sender: Any) {
        saveButton.isEnabled = editCategoryField.text != ""
    }
    
    @IBAction func saveEditName(_ sender: Any) {
        try! self.realm.write {
            getCategory.name = editCategoryField.text ?? ""
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
}
