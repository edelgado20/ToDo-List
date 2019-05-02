//
//  AddItemVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 8/10/18.
//  Copyright © 2018 Edgar Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class AddItemVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var realm: Realm!
    var category: Category = Category()
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var itemDescripField: UITextView!
    @IBOutlet weak var importImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var imagePickerController: UIImagePickerController?
    var imageNames: [String] = [] // URL Strings
    var goingForwards: Bool = false // Used to detect when the back button is tapped in the navigation controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        itemNameField.delegate = self
        // Hides the keyboard when user taps anywhere else other than the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        realm = try! Realm()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemNameField.layer.cornerRadius = 8
        itemNameField.layer.borderWidth = 1
        itemNameField.layer.borderColor = UIColor.black.cgColor

        itemDescripField.layer.cornerRadius = 8
        itemDescripField.layer.borderWidth = 1
        itemDescripField.layer.borderColor = UIColor.black.cgColor

        importImageButton.layer.cornerRadius = 8
        importImageButton.layer.borderWidth = 1
        importImageButton.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /* This checks when the user is going back or tapped on the done button without inserting a name.
           It deletes all images the were written on the disk for this uncreated item, if any. */
        if itemNameField.text?.isEmpty ?? true && !goingForwards{
            imageNames.forEach {
                try? FileService.delete(filename: $0)
            }
        }
    }
    // hides keyboard when pressed on return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        guard let imagePickerController = imagePickerController else { return }
        imagePickerController.delegate = self
        
        let actionPopUp = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .alert)
        
        actionPopUp.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            // I used a this resource https://www.andrewcbancroft.com/2018/02/24/swift-cheat-sheet-for-iphone-camera-access-usage/
            // to help out when a user decides not to allow access and then try's to access the camera. It leads them to their settins
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraStatus {
                case .notDetermined: self.requestCameraPermission()
                case .authorized: self.presentCamera()
                case .restricted, .denied: self.cameraAccessNeeded()
            @unknown default:
                print("Unknown camera status")
            }
        }))
        
        actionPopUp.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            // We set it to true because were leaving the current view controller and going forward to the imagePicker(Photo Library)
            self.goingForwards = true

            self.imagePickerController?.sourceType = .photoLibrary
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
        // We set it to true because were leaving the current view controller and going forward to the imagePicker(Photo Library)
        goingForwards = true
        
        guard let imagePickerController = imagePickerController else { return }

        self.imagePickerController?.sourceType = .camera
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
        
        // 1) Resize the image 2) Write the image to Disk
        let resizeImage = image.image(scaledToFitIn: CGSize(width: 1000, height: 1000))
        guard let url = try? FileService.write(image: resizeImage) else { return }
        
        imageNames.append(url)// temporarely append the urlString
        tableView.reloadData()
        
        goingForwards = false // back to false because we are returning to the view controller and dismissing the imagePicker(Photo Library)
        guard let imagePickerController = imagePickerController else { return }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        guard let imagePickerController = imagePickerController else { return }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let item = Item()
        item.name = itemNameField.text!
        item.descrip = itemDescripField.text
        item.id += 1
        item.category = self.category
        // Get the index based on the total items count (e.g 0,1,2,3 ...)
        let predicate = NSPredicate(format: "category = %@", category)
        let count = realm.objects(Item.self).filter(predicate).count
        item.index = count

        // Store the URL strings of the images to Realm
        item.imageNames.append(objectsIn: imageNames)
        
        // Do not add an item without a name
        if !item.name.isEmpty {
            try! self.realm.write {
                self.realm.add(item)
            }
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
}

class ImageCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            imgView.layer.cornerRadius = 10.0
        }
    }
    
}

extension AddItemVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
        let image = try? FileService.readImage(from: imageNames.reversed()[indexPath.row])
        cell.imgView.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Get the image ratio to calculate the cell height dynamically
        if let image = try? FileService.readImage(from: imageNames.reversed()[indexPath.row]) {
            let imageRatio = image.getImageRatio()
            return tableView.frame.width / imageRatio
        } else {
            return tableView.frame.width / 1.77
        }
    }
}

extension UIImage {
    func getImageRatio() -> CGFloat {
        let imageRatio = CGFloat(self.size.width / self.size.height)
        return imageRatio
    }
    
    func image(scaledToFitIn targetSize: CGSize) -> UIImage {
        
        let normalizedSelf = self.normalizedImage()
        
        let imageWidth = normalizedSelf.size.width * normalizedSelf.scale
        let imageHeight = normalizedSelf.size.height * normalizedSelf.scale
        
        if imageWidth <= targetSize.width && imageHeight <= targetSize.height {
            return normalizedSelf
        }
        
        let widthRatio = imageWidth / targetSize.width
        let heightRatio = imageHeight / targetSize.height
        let scaleFactor = max(widthRatio, heightRatio)
        let scaledSize = CGSize(width: imageWidth / scaleFactor, height: imageHeight / scaleFactor)
        
        return normalizedSelf.image(scaledToSizeInPixels: scaledSize)
    }
    
    func normalizedImage() -> UIImage {
        if (self.imageOrientation == .up) {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale)
        draw(in: CGRect(origin: .zero, size: self.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func image(scaledToSizeInPixels targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1)
        draw(in: CGRect(origin: .zero, size: targetSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
