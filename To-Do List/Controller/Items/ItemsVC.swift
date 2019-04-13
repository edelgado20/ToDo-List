//
//  ItemsVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import MobileCoreServices

class ItemsVC: UIViewController {

    @IBOutlet weak var TABLEVIEW: UITableView!
    
    var realm: Realm? = nil
    var category: Category!
    let itemsList = List<Item>()
   
    var itemsResults: Results<Item>? {
        get {
            let predicate = NSPredicate(format: "category = %@", category)
            //first sort by the index and then by completed
            return realm?.objects(Item.self).filter(predicate).sorted(byKeyPath: "index").sorted(byKeyPath: "completed")
        }
    }

    // segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
   
        if identifier == "edit_Item_Segue" {
            let cell = sender as! UITableViewCell
            let indexPath = TABLEVIEW.indexPath(for: cell)
            let editItemVC = segue.destination as! Edit_Item_VC
            editItemVC.getItem = itemsResults![(indexPath!.row)]
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
        return itemsResults?.count ?? 0
    }

    func tableView(_ TABLEVIEW: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TABLEVIEW.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
        guard let item = itemsResults?[indexPath.row] else {
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete images from the FileService if any
            let item = itemsResults![indexPath.row]
            for imageName in item.imageNames {
                try? FileService.delete(filename: imageName)
            }
            // Delete item realm object
            try! realm?.write {
                realm?.delete(itemsResults![indexPath.row])
            }
        }
        tableView.reloadData() //reloads table view up to date
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // Convert itemsResults to an array if not nill or else to an empty array
        var itemsArray = itemsResults.map { Array($0) } ?? []
        // Do the modifications on the array
        let movedItem = itemsArray[sourceIndexPath.row]
        itemsArray.remove(at: sourceIndexPath.row)
        itemsArray.insert(movedItem, at: destinationIndexPath.row)
        
        // Loop through itemsArray and fetch the item object from the realm DB associated with the same item id
        // and change the item object to the current index
        for (index, item) in itemsArray.enumerated() {
            let object = realm?.object(ofType: Item.self, forPrimaryKey: item.id)
            try! realm?.write {
                object?.index = index
            }
        }
    }
}

extension ItemsVC: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let string = itemsResults?[indexPath.row]
        guard let data = string?.name.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)

        return [UIDragItem(itemProvider: itemProvider)]
    }
}

extension ItemsVC: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath
        destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
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
}

extension ItemsVC: ItemCellDelegate {
    
    func didTapCheckbox(cell: UITableViewCell) {
        
        let index = TABLEVIEW.indexPath(for: cell)
        try! realm?.write {
            itemsResults?[(index?.row)!].completed = !(itemsResults?[(index?.row)!].completed ?? false)
        }
        TABLEVIEW.reloadData()
    }
    
}

// Expand UIButton's Clickable Area http://www.sthoughts.com/2015/04/25/swift-expand-uibuttons-clickable-area/
extension UIButton {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}
