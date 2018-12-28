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

    var str = ""
    
    @IBOutlet weak var TABLEVIEW: UITableView!
    
    var realm: Realm? = nil
    var category: Category!
   
    var itemsArray: Results<Item>? {
        get {
            print("Category: \(category)")
            return realm?.objects(Item.self)
        }
    }
    
    func tableView(_ TABLEVIEW: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray?.count ?? 0
    }
    
    func tableView(_ TABLEVIEW: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TABLEVIEW.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemsArray![indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        
        if let btnChk = cell.contentView.viewWithTag(2) as? UIButton {
            btnChk.addTarget(self, action: #selector(checkboxClicked(_ :)), for: .touchUpInside)
        }
        
        return cell
    }
    
    // segue way to edit view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "editItem_vc")
        let edit = controller as? Edit_Item_VC
        edit?.getItem = itemsArray?[indexPath.row] ?? Item()
        self.navigationController?.pushViewController(controller!, animated: true)
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
        
        print("ITEMS VC: \(str)")
        realm = try! Realm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TABLEVIEW.reloadData() //reloads any new item into the table view(display)
    }
    
    @objc func checkboxClicked(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
    }

}
