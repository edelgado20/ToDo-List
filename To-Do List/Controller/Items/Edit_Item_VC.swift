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
    let dateFormat = "MM-dd-yyyy"
    var currentYear = 0
    var currentDate = ""
    var globalDueDate: Date?
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
        
        // Get all images from the Item realm object
        importedImages.append(contentsOf: getItem.imageNames)
        self.title = "Edit \(getItem.name)"
        
        // Hides the keyboard when user taps anywhere else other than the keyboard
        // https://stackoverflow.com/questions/34030387/uitableview-didselectrowatindexpath-not-being-called
//        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
//        tapGesture.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGesture)
        
        tableView.tableFooterView = UIView() // remove empty cells if tableView is empty
        
        /* GlobalDueDate is used to keep a hold of its value and save it to realm if it has a value on viewWillDissappear */
        globalDueDate = getItem.dueDate
        
        // SetUp Current Date
        let date = Date()
        let components = Calendar.current.dateComponents([.month, .day, .year], from: date)
        if let month = components.month, let day = components.day, let year = components.year {
            currentDate = "\(month)-\(day)-\(year)"
            currentYear = year
        }
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
        
        // Checking to see if the GlobalDueDate has a value and its value is not the same as the one on realm
        if globalDueDate != nil && getItem.dueDate != globalDueDate {
            try! self.realm?.write {
                getItem.dueDate = globalDueDate
            }
        }
        
        if self.view.subviews.contains(datePicker) {
            datePicker.removeFromSuperview()
            toolBar.removeFromSuperview()
        }
    }
    
    private func setViewModels(from item: Item) {
        // Unwrapping Optional
        var dueDateFormatted: String = ""
        if let dueDate = getItem.dueDate {
            dueDateFormatted = dueDateFormatter(dueDate: dueDate)
        } else {
            dueDateFormatted = "Due Date"
        }

        viewModels = [
            .init(icon: #imageLiteral(resourceName: "calendar"), title: dueDateFormatted),
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touches began")
        datePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    // MARK: Image Picker
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
    
    // MARK: Date Picker
    func showDatePicker() {
        
        // Checks if a DatePicker is already being displayed
        if self.view.subviews.contains(datePicker){
            return
        }
        
        // DatePicker https://medium.com/@javedmultani16/uidatepicker-in-swift-3-and-swift-4-example-35a1f23bca4b
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: self.view.frame.height - 216, width: self.view.frame.width, height: 216))
        datePicker.datePickerMode = .date
        datePicker.setDate(getItem.dueDate ?? Date(), animated: true)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        self.view.addSubview(datePicker)
        
        // Create a new cell to replace the current one and add the dueDate text on the label
        let indexPath = IndexPath(item: FieldRow.dueDate.rawValue, section: TableSection.fields.rawValue)
        let cell = tableView.cellForRow(at: indexPath) as! EditItemVC_FieldCell
        
        // Unwrapping Optional
        var dueDateString: String = ""
        if let date = getItem.dueDate {
            dueDateString = dueDateFormatter(dueDate: date)
        } else {
            dueDateString = dueDateFormatter(dueDate: Date())
        }
        cell.fieldLabel.text = dueDateString
        cell.fieldLabel.highlightedTextColor = UIColor.init(hexString: "0066FF")
        
        // ToolBar
        toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.height - 260, width: self.view.frame.width, height: 44))
        toolBar.sizeToFit()
        let removeButton = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(cancelDatePicker))
        removeButton.tintColor = UIColor.black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDatePicker))
        toolBar.setItems([removeButton, spaceButton, doneButton], animated: true)
        self.view.addSubview(toolBar)
       
        // Added a custom view to be able to use the touchesBegan func and dismiss the datePicker when user touches outside
        let customView = UIView(frame: CGRect(x: 0, y: 118, width: self.view.frame.width, height: self.view.frame.height - 378))
        customView.backgroundColor = UIColor.yellow
        self.view.addSubview(customView)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        
        let dueDateFormatted = dueDateFormatter(dueDate: sender.date)
        
        // Getting the dueDate cell to update the label with the dueDate
        let indexPath = IndexPath(item: FieldRow.dueDate.rawValue, section: TableSection.fields.rawValue)
        let cell = tableView.cellForRow(at: indexPath) as! EditItemVC_FieldCell
        cell.fieldLabel.text = dueDateFormatted
    }
    
    func dueDateFormatter(dueDate: Date) -> String {
        self.globalDueDate = dueDate // global variable that get's assigned to realm object
        
        let components = Calendar.current.dateComponents([.month, .day, .year, .weekday], from: dueDate)

        if let month = components.month, let day = components.day, let year = components.year, let weekday = components.weekday {
            /* The variable date and dueDate are almost the same value except that date doesn't have zero's on their day or month and dueDate does */
            let date = "\(month)-\(day)-\(year)"
            let dueDate = Calendar.current.date(from: components)!
            let dayOfWeek = convertToDayOfWeek(day: weekday)
            let monthString = convertToMonth(month: month)
            
            if date == currentDate {
                return "Due Today"
            }
        
            /* Formating the dueDate to MM-dd-yyyy format to check if the dueDate is a yesterday or tomorrow */
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dueDateTrim = formatter.string(from: dueDate)
            
            let tomorrowString = tomorrow()
            if dueDateTrim == tomorrowString {
                return "Due Tomorrow"
            }
            
            let yesterdayString = yesterday()
            if dueDateTrim == yesterdayString {
                return "Due Yesterday"
            }
            
            if year == currentYear {
                return "Due \(dayOfWeek), \(monthString) \(day)"
            } else {
                return "Due \(dayOfWeek), \(monthString) \(day), \(year)"
            }
        } else {
            return "Due Date"
        }
    }
    
    // http://h4labs.org/calculating-yesterday-and-tomorrow-in-swift/
    func tomorrow() -> String {
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day) // +1 day
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: dateComponents, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let tomorrowTrim = formatter.string(from: tomorrow)
        
        return tomorrowTrim
    }
    
    func yesterday() -> String {
        var dateComponents = DateComponents()
        dateComponents.setValue(-1, for: .day) // -1 day
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: dateComponents, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let yesterdayTrim = formatter.string(from: yesterday)
        
        return yesterdayTrim
    }
    
    func convertToDayOfWeek(day: Int) -> String {
        switch day {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        default:
            return "Sat"
        }
    }
    
    func convertToMonth(month: Int) -> String {
        switch month {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        default:
            return "December"
        }
    }
    
    @objc func cancelDatePicker() {
        // Set to nil if there is a due date value on the object
        if (getItem.dueDate != nil)  {
            try! realm?.write {
                getItem.dueDate = nil
            }
        }
        globalDueDate = nil
    
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        
        let indexPosition = IndexPath(row: FieldRow.dueDate.rawValue, section: TableSection.fields.rawValue)
        tableView.reloadRows(at: [indexPosition], with: .fade)
    }
    
    @objc func doneDatePicker() {
        if globalDueDate != nil {
            try! realm?.write {
                getItem.dueDate = globalDueDate
            }
        }
        
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
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
