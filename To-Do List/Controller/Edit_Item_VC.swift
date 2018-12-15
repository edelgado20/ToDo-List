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
    
    var getItem = Item()

    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        
        editName.text = getItem.name
        editDescription.text = getItem.descrip
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! self.realm?.write {
            getItem.name = editName.text ?? ""
            getItem.descrip = editDescription.text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}
