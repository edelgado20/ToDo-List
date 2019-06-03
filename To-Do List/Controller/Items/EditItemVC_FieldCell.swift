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
    }
    
    func configure(with viewModel: ViewModel) {
        iconPlaceholder.image = viewModel.icon
        fieldLabel.text = viewModel.title
    }
    
    
}
