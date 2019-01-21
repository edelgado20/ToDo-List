//
//  ItemsVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ItemsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //private let networkingClient = NetworkingClient()
    @IBOutlet weak var TABLEVIEW: UITableView!
    
    var realm: Realm? = nil
    var category: Category!
   
    var itemsArray: Results<Item>? {
        get {
            let predicate = NSPredicate(format: "category = %@", category)
            return realm?.objects(Item.self).filter(predicate).sorted(byKeyPath: "completed")
        }
    }
    
    func tableView(_ TABLEVIEW: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray?.count ?? 0
    }
    
    func tableView(_ TABLEVIEW: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TABLEVIEW.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
        guard let item = itemsArray?[indexPath.row] else {
            return cell
        }
        
        cell.setUpCell(item: item)
        cell.delegate = self
        
        return cell
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
        
        //print("Items VC before fetching getItems")

//        networkingClient.getItems { (result: Result<[Item]>) -> Void in
//            switch result {
//            case .success(let items):
//                print("hello items")
//                //print("Items: \(items)")
//            case .failure(let error):
//                print("Error: \(error.localizedDescription)")
//            }
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        TABLEVIEW.reloadData() //reloads any new item into the table view(display)
    }
}

extension ItemsVC: ItemCellDelegate {
    
    func didTapCheckbox(cell: UITableViewCell) {
        
        let index = TABLEVIEW.indexPath(for: cell)
        try! realm?.write {
            itemsArray?[(index?.row)!].completed = !(itemsArray?[(index?.row)!].completed ?? false)
        }
        TABLEVIEW.reloadData()
    }
    
}
