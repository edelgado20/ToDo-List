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
        var attributedText: NSAttributedString?
    }
    
    func configure(with viewModel: ViewModel) {
        iconPlaceholder.image = viewModel.icon
        
//        let titleString = "Remind me at 8:00 PM"
//        let titleFont = UIFont.systemFont(ofSize: 12)
//        let titleAttributes = [NSAttributedString.Key.font: titleFont]
//        let mutableTitle = NSMutableAttributedString(string: "\(titleString)\n", attributes: titleAttributes)
//
//        let subtitleFont = UIFont.systemFont(ofSize: 8)
//        let subtitleAttributes = [NSAttributedString.Key.font: subtitleFont]
//        let mutableSubtitle = NSMutableAttributedString(string: Date().description, attributes: subtitleAttributes)
//        mutableTitle.append(mutableSubtitle)
//        fieldLabel.attributedText = mutableTitle
        
        if let subText = viewModel.attributedText {
            fieldLabel.attributedText = subText // NSAttributedString (Title & Subtitle)
        } else {
            fieldLabel.text = viewModel.title
        }
        fieldLabel.textColor = viewModel.textColor
    }
}
