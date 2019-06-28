//
//  EditItemTableViewCell.swift
//  To-Do List
//
//  Created by Edgar Delgado on 6/1/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import UIKit

class EditItemVC_FieldCell: UITableViewCell {
    @IBOutlet weak var iconPlaceholder: UIImageView!
    @IBOutlet weak var fieldLabel: UILabel!
    
    struct ViewModel {
        var icon: UIImage?
        var title: String?
        var textColor: UIColor?
    }
    
    func configure(with viewModel: ViewModel) {
        iconPlaceholder.image = viewModel.icon
        fieldLabel.text = viewModel.title
        fieldLabel.textColor = viewModel.textColor
    }
}

//class Cell: UITableViewCell {
//
//    @IBOutlet weak var detailLabel: UILabel!
//
//}
//
//
//
//class ViewController: UIViewController {
//
//    let data = (0..<10).map {$0}
//
//    var hiddenIndices = Set<Int>()
//
//}
//
//
//
//extension ViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return data.count
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell =  tableView.dequeueReusableCell(withIdentifier: "a", for: indexPath)
//
//        if let cell = cell as? Cell {
//
//            cell.detailLabel.isHidden = hiddenIndices.contains(indexPath.row)
//
//        }
//
//        return cell
//
//    }
//
//}
//
//
//
//extension ViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        if hiddenIndices.contains(indexPath.row) {
//
//            hiddenIndices.remove(indexPath.row)
//
//        } else {
//
//            hiddenIndices.insert(indexPath.row)
//
//        }
//
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//
//    }
//
//}
