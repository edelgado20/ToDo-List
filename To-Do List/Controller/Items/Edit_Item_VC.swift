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
    @IBOutlet weak var collectionView: UICollectionView!
    
    var getItem = Item()
    var imageStringNames: [String] = []
    var newImportedImages = [String]()
    let imagePickerController = UIImagePickerController()
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
    
    @IBAction func importButtonPressed(_ sender: Any) {
        imagePickerController.delegate = self
        
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
            
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
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
        
        self.imagePickerController.sourceType = .camera
        self.present(self.imagePickerController, animated: true, completion: nil)
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
        collectionView.reloadData()
        
        goingForwards = false // back to false because we are returning to the view controller and dismissing the imagePicker(Photo Library)
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
}

class CollectionImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 10.0
        }
    }
}

extension Edit_Item_VC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageStringNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionImageCell
        let image = try? FileService.readImage(from: imageStringNames.reversed()[indexPath.row])
        cell.imageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let image = try? FileService.readImage(from: imageStringNames.reversed()[indexPath.row]) {
            let imageRatio = image.getImageRatio()
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / imageRatio)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 1.5)
        }
    }
}


