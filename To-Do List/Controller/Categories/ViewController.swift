//
//  ViewController.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/9/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var itemsToDeleteInFileService: Results<Item>? {
        // Delete all posible images of all items being deleted from the file service
        didSet {
            for item in self.itemsToDeleteInFileService! {
                for image in item.imageNames {
                    try? FileService.delete(filename: image)
                }
            }
        }
    }

    var realm: Realm? = nil
    var token: NotificationToken?
    lazy var categoriesArray: Results<Category>? = {
        return realm?.objects(Category.self)
    }()
    
    // returns the count number to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 0
    }
    
    // loops through the table view and display every cell 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        guard let category = categoriesArray?[indexPath.row] else {
            return cell
        }

        cell.setCategoryCell(category: category)
        //cell.textLabel?.text = categoriesArray![indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, nil) in
            let cell = tableView.cellForRow(at: indexPath)
            self.performSegue(withIdentifier: "showEditCategory", sender: cell)
        }
        edit.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak realm, weak categoriesArray, weak token, weak self] (action, view, nil) in
            guard let realm = realm, let categoriesArray = categoriesArray, let self = self else { return }
            print("Delete")
            //token?.invalidate()
            try? realm.write {
                let category = categoriesArray[indexPath.row]
                let itemsToDelete = realm.objects(Item.self).filter("category.id == \"\(category.id)\"")
                self.itemsToDeleteInFileService = itemsToDelete
                realm.delete(itemsToDelete)
                realm.delete(category)
            }

            tableView.reloadData()
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareForSegue")
        //guard let identifier = segue.identifier else { return }
        
        switch segue.destination {
        case let vc as ItemsVC:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            vc.category = categoriesArray![indexPath.row]
            
        case let vc as EditCategoryVC:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            vc.getCategory = categoriesArray![(indexPath?.row)!]
            
        default:
            break
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    private func reloadCategories() {
        token = categoriesArray?.observe { [weak tableView] (changes: RealmCollectionChange) in
            guard let tableView = tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        tableView.reloadData()
    }

}

