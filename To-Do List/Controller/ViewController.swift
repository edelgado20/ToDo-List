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
    
    // returns the count number to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 0
    }
    // loops through the table view and display every cell 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = categoriesArray![indexPath.row].name
        cell.accessoryType = .disclosureIndicator // add the disclosure indicater(>) in each cell
        return cell
    }
    
    //function to delete a category
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            realm?.beginWrite()
            realm?.delete(categoriesArray![indexPath.row])
            try? realm?.commitWrite()
        }
        tableView.reloadData()
    }
    
    //switch to items_vc
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segue to items list view
        
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard?.instantiateViewController(withIdentifier: "items_vc")
        self.navigationController?.pushViewController(controller!, animated: true)
        
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "items_vc") as? ItemsVC else {
//            return print("not items vc")
//        }
        
//        vc.str = categoriesArray?[indexPath.row].name ?? "string"
//        navigationController?.present(vc, animated: true, completion: {})
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

