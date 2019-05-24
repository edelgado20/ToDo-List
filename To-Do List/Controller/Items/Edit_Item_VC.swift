//
//  Edit_Item_VC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/12/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class Edit_Item_VC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var realm: Realm? = nil
    
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editDescription: UITextView!
    @IBOutlet weak var saveItemButton: UIBarButtonItem!
    @IBOutlet weak var importImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let cellHeaderSpacingHeight: CGFloat = 8
    var getItem = Item()
    var imageStringNames: [String] = []
    var newImportedImages = [String]()
    var imagePickerController: UIImagePickerController?
    var goingForwards: Bool = false // Detect when the back button is tapped in the nav controller to delete images from the file service

    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        //Get all images from the Item realm object
        imageStringNames.append(contentsOf: getItem.imageNames)
        self.title = "Edit \(getItem.name)"
        editName.delegate = self
        
        // Hides the keyboard when user taps anywhere else other than the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        tableView.tableFooterView = UIView() // remove empty cells if tableView is empty
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // This boolean checks when the user is going back. It deletes all images the were written on the FileService/Disk
        if !goingForwards {
            newImportedImages.forEach {
                try? FileService.delete(filename: $0)
            }
        }
    }
    // hides keyboard when pressed on return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveEditItem(_ sender: Any) {
        goingForwards = true // bool prevents from deleting the images on the file service on the viewDisapper()
        try! self.realm?.write {
            getItem.name = editName.text ?? ""
            getItem.descrip = editDescription.text
            getItem.imageNames.append(objectsIn: newImportedImages)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func itemNameTextField(_ sender: Any) {
        saveItemButton.isEnabled = editName.text != ""
    }
    
    // MARK: Handling Image Picker
    @IBAction func importButtonPressed(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        
        let actionPopUp = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .alert)
        
        actionPopUp.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            // Resource: https://www.andrewcbancroft.com/2018/02/24/swift-cheat-sheet-for-iphone-camera-access-usage/
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraStatus {
            case .notDetermined: self.requestCameraPermission()
            case .authorized: self.presentCamera()
            case .restricted, .denied: self.cameraAccessNeeded()
            @unknown default:
                print("unknown camera status")
            }
        }))
        
        actionPopUp.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            // We set it to true because were leaving the current view controller and going forward to the imagePicker(Photo Library)
            self.goingForwards = true
            
            guard let imagePickerController = self.imagePickerController else { return }
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionPopUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionPopUp, animated: true, completion: nil)
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { accessGranted in
            guard accessGranted == true else { return }
            self.presentCamera()
        })
    }
    
    func presentCamera() {
        // Set to true because were leaving the current view controller and going forward to the imagePicker(Photo Library)
        goingForwards = true
        
        guard let imagePickerController = self.imagePickerController else { return }
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func cameraAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        let alert = UIAlertController(title: "Need Camera Access",
                                      message: "Camera access is required to take a photo",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert: UIAlertAction) in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as! UIImage? else { return }
        // 1) Resize the image 2) Write the image to Disk(FileService)
        let resizeImage = image.image(scaledToFitIn: CGSize(width: 1000, height: 1000))
        guard let urlString = try? FileService.write(image: resizeImage) else { return }
        
        imageStringNames.append(urlString) // array that displays data on the collection view
        newImportedImages.append(urlString) // used to manage new images to posibly add them to realm or delete them from disk
        tableView.reloadData()
        
        goingForwards = false // back to false because we are returning to the view controller and dismissing the imagePicker(Photo Library)
        self.imagePickerController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController?.dismiss(animated: true, completion: nil)
    }
}

class TableViewImageCell: UITableViewCell {
    @IBOutlet weak var imageViewPlaceholder: UIImageView!
}

extension Edit_Item_VC: UITableViewDataSource, UITableViewDelegate {
    // Create a new section(rather than a row) for each item, so sections can then be spaced using section header height
    // https://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell/33931591#33931591
    func numberOfSections(in tableView: UITableView) -> Int {
        return imageStringNames.count
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeaderSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! TableViewImageCell
        let image = try? FileService.readImage(from: imageStringNames.reversed()[indexPath.section])
        cell.imageViewPlaceholder.image = image
        cell.layer.cornerRadius = 10
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let image = try? FileService.readImage(from: imageStringNames.reversed()[indexPath.section]) {
            let imageCrop = image.getImageRatio()
            return tableView.frame.width / imageCrop
        } else {
            return tableView.frame.width / 1.77
        }
    }
    
    // deletes image
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            /* Remove the item from the data model (Local Array & posibly RealmDB) */
            // We remove the image from the array this way because the images are displayed reversed on the tableView
            let count = self.imageStringNames.count
            let index = (count - 1) - indexPath.section
            let imageString = self.imageStringNames.remove(at: index)
            // Removes if it's a newImage that gets deleted before tapping save to make sure it doesn't save it to realm
            self.newImportedImages.removeAll(where: { $0 == imageString })
            
            if self.getItem.imageNames.contains(imageString) {
                // remove from RealmDB
                try! self.realm?.write {
                    self.getItem.imageNames.remove(at: index)
                }
            }
            // remove from FileService
            try? FileService.delete(filename: imageString)
            
            // delete the tableView section
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            self.tableView.deleteSections(indexSet, with: .fade)
            
            completion(true)
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = .red
        
        return action
    }
}
