//
//  Edit_Item_VC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/12/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift

class Edit_Item_VC: UIViewController {
    var realm: Realm? = nil
    
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editDescription: UITextView!
    @IBOutlet weak var saveItemButton: UIBarButtonItem!
    @IBOutlet weak var importImageButton: UIButton!
    @IBOutlet weak var CollectionView: UICollectionView!
    
    var getItem = Item()
    var imageStringNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        for imageName in getItem.imageNames {
            imageStringNames.append(imageName)
        }
        self.title = "Edit \(getItem.name)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editName.text = getItem.name
        editName.layer.cornerRadius = 8
        editName.layer.borderWidth = 1
        editName.layer.borderColor = UIColor.black.cgColor
        
        editDescription.text = getItem.descrip
        editDescription.layer.cornerRadius = 8
        editDescription.layer.borderWidth = 1
        editDescription.layer.borderColor = UIColor.black.cgColor
        
        importImageButton.layer.cornerRadius = 8
        importImageButton.layer.borderWidth = 1
        importImageButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func saveEditItem(_ sender: Any) {
        try! self.realm?.write {
            getItem.name = editName.text ?? ""
            getItem.descrip = editDescription.text
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func itemNameTextField(_ sender: Any) {
        saveItemButton.isEnabled = editName.text != ""
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        print("import button pressed")
    }
}

class CollectionImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

extension Edit_Item_VC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageStringNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionImageCell
        let image = try? FileService.readImage(from: imageStringNames[indexPath.row])
        cell.imageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let image = try? FileService.readImage(from: imageStringNames[indexPath.row]) {
            let imageRatio = image.getImageRatio()
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / imageRatio)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 1.5)
        }
    }
}


