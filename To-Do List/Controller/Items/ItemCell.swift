//
//  ItemCell.swift
//  To-Do List
//
//  Created by COFEBE, inc. on 1/7/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import UIKit

protocol ItemCellDelegate: class {
    func didTapCheckbox(cell: UITableViewCell)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    weak var delegate: ItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func checkboxTapped(_ sender: Any) {
        delegate?.didTapCheckbox(cell: self)
    }
    
    func setUpCell(item: Item){
        //self.accessoryType = .disclosureIndicator

        if item.completed {
            checkboxButton.alpha = 0.5
            backgroundCardView.backgroundColor = UIColor(white: 1, alpha: 0.5)
            
            let itemNameString = NSMutableAttributedString(string: item.name)
            itemNameString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, itemNameString.length))
            itemNameString.addAttribute(.foregroundColor, value: UIColor(white: 0, alpha: 0.5), range: NSMakeRange(0, itemNameString.length))
            itemLabel.attributedText = itemNameString
        } else {
            checkboxButton.alpha = 1.0
            itemLabel.attributedText = NSAttributedString(string: item.name)
            backgroundCardView.backgroundColor = UIColor.white
        }

        //contentView.backgroundColor = UIColor.orange
        backgroundCardView.layer.cornerRadius = 3.0
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
        
        checkboxButton.isSelected = item.completed
    }
    

}
