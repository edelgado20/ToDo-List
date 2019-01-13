//
//  ViewController.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/9/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    private let networkingClient = NetworkingClient()
    var realm: Realm? = nil
    var token: NotificationToken?
    @IBOutlet weak var tableView: UITableView!
    lazy var categoriesArray: Results<Category>? = {
        return realm?.objects(Category.self)
    }()
    // Items that their category is deleted are added to this list
//    var nullItemsArray: Results<Item> {
//        return ((realm?.objects(Item.self).filter("category == nil"))!)
//    }
    
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, nil) in
            let cell = tableView.cellForRow(at: indexPath)
            self.performSegue(withIdentifier: "showEditCategory", sender: cell)
        }
        edit.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak realm, weak categoriesArray, weak token, weak self] (action, view, nil) in
            guard let realm = realm, let categoriesArray = categoriesArray, let self = self else {
                return
            }
            print("Delete")
            token?.invalidate()
            try? realm.write {
                let category = categoriesArray[indexPath.row]
                let itemsToDelete = realm.objects(Item.self).filter("category.id == \"\(category.id)\"")
                realm.delete(itemsToDelete)
                realm.delete(category)
            }
            self.subscribeCategories()
            //tableView.reloadData()
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
    
    private func subscribeCategories() {
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
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        subscribeCategories()
        
        networkingClient.getCategories { (result: Result<[Category]>) -> Void in
            switch result {
            case .success(let categories):
                print("Categories: \(categories)")
                try? self.realm?.write {
                    self.realm?.add(categories, update: true)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}

