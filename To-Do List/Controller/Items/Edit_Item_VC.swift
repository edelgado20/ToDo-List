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
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellHeaderSpacingHeight: CGFloat = 8
    var getItem = Item()
    var importedImages: [String] = [] // array containing all importedImages for tableview data
    var newImportedImages: [String] = [] // array for new importedImages (use to add to realm)
    var imagePickerController: UIImagePickerController?
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    var viewModels: [EditItemVC_FieldCell.ViewModel] = []
    
    enum TableSection: Int {
        case fields = 0
        case images = 1
    }
    
    enum FieldRow: Int {
        case dueDate = 0
        case reminder = 1
        case note = 2
        case importImage = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        
        //Get all images from the Item realm object
        importedImages.append(contentsOf: getItem.imageNames)
        self.title = "Edit \(getItem.name)"
        
        // Hides the keyboard when user taps anywhere else other than the keyboard
        // https://stackoverflow.com/questions/34030387/uitableview-didselectrowatindexpath-not-being-called
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        tableView.tableFooterView = UIView() // remove empty cells if tableView is empty
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setViewModels(from: getItem)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /* Realm Writes are expensive so instead of doing a write transaction everytime we add an image we instead check before the view will disappear and check if there is any new images in the newImportedImages array */
        if newImportedImages.count > 0 {
            try! self.realm?.write {
                getItem.imageNames.append(objectsIn: newImportedImages)
            }
            newImportedImages.removeAll()
        }
    }
    
    private func setViewModels(from item: Item) {
        viewModels = [
            .init(icon: #imageLiteral(resourceName: "calendar"), title: item.dueDate.isEmpty ? "Due Date" : item.dueDate),
            .init(icon: #imageLiteral(resourceName: "bell"), title: "Reminder"),
            .init(icon: #imageLiteral(resourceName: "pen"), title: item.descrip.isEmpty ? "Add a note..." : item.descrip),
            .init(icon: #imageLiteral(resourceName: "paperclipIcon"), title: "Import an image")
        ]
    }
    
    // hides keyboard when pressed on return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Handling Image Picker
    func importImageCellPressed() {
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
        newImportedImages.append(urlString)
        importedImages.append(urlString)
        
        tableView.reloadData()

        self.imagePickerController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController?.dismiss(animated: true, completion: nil)
    }
    
    func showDatePicker() {
        // DatePicker
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: self.view.frame.height - 216, width: self.view.frame.width, height: 216))
        datePicker.datePickerMode = .date
        self.view.addSubview(datePicker)
        
        // ToolBar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.height - 246, width: self.view.frame.width, height: 50))
        toolbar.sizeToFit()
        let removeButton = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(cancelDatePicker))
        removeButton.tintColor = UIColor.black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDatePicker))
        toolbar.setItems([removeButton, spaceButton, doneButton], animated: true)
        self.view.addSubview(toolbar)
    }
    
    @objc func cancelDatePicker() {
        print("CancelDatePicker")
    }
    
    @objc func doneDatePicker() {
        print("DoneDatePicker")
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) { print("unwind") }
}

extension Edit_Item_VC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == TableSection.fields.rawValue {
            return viewModels.count
        } else {
            return importedImages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == TableSection.fields.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell", for: indexPath)
            (cell as? EditItemVC_FieldCell)?.configure(with: viewModels[indexPath.row]) // setup cell
            
            // Create a background view to change the cell color when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.init(hexString: "#CDDFF4")
            cell.selectedBackgroundView = backgroundView
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! EditItemVC_ImageCell
            let image = try? FileService.readImage(from: importedImages.reversed()[indexPath.row])
            cell.imgView.image = image
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Section
        if indexPath.section == TableSection.fields.rawValue {
            // Row
            switch indexPath.row {
            case FieldRow.dueDate.rawValue:
                print("DueDate: \(7)")
                showDatePicker()
            case FieldRow.note.rawValue:
                let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteVC
                noteVC.note = getItem.descrip
                noteVC.subtitle = getItem.name
                present(noteVC, animated: true, completion: nil)
            case FieldRow.importImage.rawValue:
                importImageCellPressed()
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                print("None of the above")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == TableSection.fields.rawValue {
            return UITableView.automaticDimension // for stack view
        } else { // Images Section
            // Get the image ratio to calculate the cell height dynamically
            if let image = try? FileService.readImage(from: importedImages.reversed()[indexPath.row]) {
                let imageRatio = image.getImageRatio()
                /* Calculation: Get the tableView width minus the leading and trailing constraints divided by the imageRatio. Then add the top and bottom constraints */
                return ((tableView.frame.width-56) / imageRatio) + 8
            } else { //No Image
                return 0
            }
        }
    }
    
    // Only enables the Images TableView Section to be edited/deleted
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == TableSection.images.rawValue {
            return true
        }
        return false
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
            let count = self.importedImages.count
            let index = (count - 1) - indexPath.row
            let imageString = self.importedImages.remove(at: index)
            // Removes the image if it's a newImage that gets deleted before saving it to realm (write transaction on viewWillDisappear)
            self.newImportedImages.removeAll(where: { $0 == imageString })

            if self.getItem.imageNames.contains(imageString) {
                // remove from RealmDB
                try! self.realm?.write {
                    self.getItem.imageNames.remove(at: index)
                }
            }
            // remove from FileService
            try? FileService.delete(filename: imageString)
            
            // delete the tableView row
            let indexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            self.tableView.deleteRows(at: [indexPath], with: .fade)

            completion(true)
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = .red

        return action
    }
}
