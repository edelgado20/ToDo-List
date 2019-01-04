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
    
    @IBAction func saveCategoryName(_ sender: Any) {
        try! self.realm.write {
            getCategory.name = editCategoryField.text ?? ""
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
