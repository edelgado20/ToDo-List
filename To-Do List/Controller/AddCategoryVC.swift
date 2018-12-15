//
//  AddCategoryVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class AddCategoryVC: UIViewController, UITextFieldDelegate{
    
    var realm: Realm!

    @IBOutlet weak var catNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        catNameTextField.delegate = self
        doneButton.isEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)!{
            doneButton.isEnabled = true
        }
        else{
            doneButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTap(_ sender: Any) {
        let category = Category()
        category.name = catNameTextField.text!
       
        try! self.realm.write {
            self.realm.add(category)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
}
