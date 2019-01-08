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
        self.textLabel?.text = item.name
        self.accessoryType = .disclosureIndicator
        
        checkboxButton.isSelected = item.completed
    }
    

}
