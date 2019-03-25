//
//  ItemsVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

/*
 1. Tell the table view that you want to be able to move rows around
 2. Update the data model && Update the tableview UI
 */
import UIKit
import RealmSwift
import MobileCoreServices

class ItemsVC: UIViewController {

    @IBOutlet weak var TABLEVIEW: UITableView!
    
    var realm: Realm? = nil
    var category: Category!
   
    var itemsArray: Results<Item>? {
        get {
            let predicate = NSPredicate(format: "category = %@", category)
            return realm?.objects(Item.self).filter(predicate).sorted(byKeyPath: "completed")
        }
    }

    // segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
   
        if identifier == "edit_Item_Segue" {
            let cell = sender as! UITableViewCell
            let indexPath = TABLEVIEW.indexPath(for: cell)
            let editItemVC = segue.destination as! Edit_Item_VC
            editItemVC.getItem = itemsArray![(indexPath!.row)]
        } else if identifier == "addItemSegue" {
            let addItemVC = segue.destination as! AddItemVC
            addItemVC.category = self.category
        } else {
            print("Error unknown identifier")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()

        TABLEVIEW.dragDelegate = self
        TABLEVIEW.dropDelegate = self
        TABLEVIEW.dragInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.title = category.name
        TABLEVIEW.reloadData() //reloads any new item into the table view(display)
    }

}

extension ItemsVC: UITableViewDataSource {
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
}

extension ItemsVC: UITableViewDelegate {
    // segue to edit view controller
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let controller = storyboard?.instantiateViewController(withIdentifier: "editItem_vc")
     let edit = controller as? Edit_Item_VC
     edit?.getItem = itemsArray?[indexPath.row] ?? Item()
     self.navigationController?.pushViewController(edit!, animated: true)
     }*/

    // deletes an item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm?.write {
                realm?.delete(itemsArray![indexPath.row])
            }
        }
        tableView.reloadData() //reloads table view up to date
    }
}

extension ItemsVC: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let string = itemsArray?[indexPath.row]
        guard let data = string?.name.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)

        return [UIDragItem(itemProvider: itemProvider)]
    }
}

extension ItemsVC: UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        print("Inside canHandle()")
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath
        destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        print("Inside dropSessionDidUpdate()")
        // The .move operation is available only for dragging within a single app.
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print("Inside performDropWith()")
        let itemsArray = Array(self.itemsArray!)
        var itemNames = nameOfItems(itemsArray: itemsArray)

        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            guard let strings = items as? [String] else { return }

            for string in strings {
                print("String: \(string)")
            }

            var indexPaths = [IndexPath]()

            for (index, string) in strings.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)

                // insert the copy to the array
                itemNames.insert(string, at: indexPath.row)

                // keep track of this new row
                indexPaths.append(indexPath)
            }

            // insert them all into the table view at once
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func nameOfItems(itemsArray: [Item]) -> [String] {
        var items = [String]()
        for item in itemsArray {
            items.append(item.name)
        }

        return items
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

// Expand UIButton's Clickable Area http://www.sthoughts.com/2015/04/25/swift-expand-uibuttons-clickable-area/
extension UIButton {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}

//extension Results {
//    func toArray<T>(ofType: T.Type) -> [T] {
//        var array = [T]()
//        for i in 0 ..< count {
//            if let result = self[i] as? T {
//                array.append(result)
//            }
//        }
//
//        return array
//    }
//}
