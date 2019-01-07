//
//  ItemsVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class ItemsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TABLEVIEW: UITableView!
    
    var realm: Realm? = nil
    var category: Category!
   
    var itemsArray: Results<Item>? {
        get {
            let predicate = NSPredicate(format: "category = %@", category)
            return realm?.objects(Item.self).filter(predicate)
        }
    }
    
    func tableView(_ TABLEVIEW: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray?.count ?? 0
    }
    
    func tableView(_ TABLEVIEW: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TABLEVIEW.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemsArray?[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        
        if let btnChk = cell.contentView.viewWithTag(2) as? UIButton {
            btnChk.addTarget(self, action: #selector(checkboxClicked(_ :)), for: .touchUpInside)
        }
        
        return cell
    }
    
    //Allows reordering of cells
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let cell = itemsArray?[sourceIndexPath.row]
        try! realm?.write {
            realm?.delete(itemsArray![sourceIndexPath.row])
            realm?.add(cell!)
        }
    }
    
    // segue to edit view controller
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "editItem_vc")
        let edit = controller as? Edit_Item_VC
        edit?.getItem = itemsArray?[indexPath.row] ?? Item()
        self.navigationController?.pushViewController(edit!, animated: true)
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
   
        if identifier == "edit_Item_Segue" {
            let cell = sender as! UITableViewCell
            let indexPath = TABLEVIEW.indexPath(for: cell)
            let editItemVC = segue.destination as! Edit_Item_VC
            print("value = \(itemsArray![indexPath!.row])")
            editItemVC.getItem = itemsArray![(indexPath!.row)]
        } else if identifier == "addItemSegue" {
            let addItemVC = segue.destination as! AddItemVC
            addItemVC.category = self.category
        } else {
            print("Error unknown identifier")
        }
    }
    
    // deletes an item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm?.write {
                realm?.delete(itemsArray![indexPath.row])
            }
        }
        tableView.reloadData() //reloads table view up to date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = category.name
        realm = try! Realm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TABLEVIEW.reloadData() //reloads any new item into the table view(display)
    }
    
    @objc func checkboxClicked(_ sender: UIButton){
        //sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            sender.isSelected = false
        } else {
            
            sender.isSelected = true
        }
        
    }

}
