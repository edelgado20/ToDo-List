//
//  ViewController.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/9/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var realm: Realm? = nil
    @IBOutlet weak var tableView: UITableView!
    var categoriesArray: Results<Category>? {
        get {
            return realm?.objects(Category.self)
        }
    }
    // Items that their category is deleted are added to this list
    var nullItemsArray: Results<Item> {
        get {
            return ((realm?.objects(Item.self).filter("category == nil"))!)
        }
    }
     
    // returns the count number to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 0
    }
    
    // loops through the table view and display every cell 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categoriesArray![indexPath.row].name
        cell.accessoryType = .disclosureIndicator // add the disclosure indicater(>) in each cell
        return cell
    }
    
    //function to delete a category
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm?.write {
                realm?.delete(categoriesArray![indexPath.row])
                realm?.delete(nullItemsArray)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, nil) in
            print("Edit")
            
        }
        edit.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            print("Delete")
            try! self.realm?.write {
                self.realm?.delete(self.categoriesArray![indexPath.row])
                self.realm?.delete(self.nullItemsArray)
            }
            tableView.reloadData()
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareForSegue")
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "showItemsVC":
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            let vc = segue.destination as! ItemsVC
            vc.category = categoriesArray![indexPath.row]
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
    // reload data to view all data in table view
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

