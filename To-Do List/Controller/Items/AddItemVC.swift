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

class AddItemVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var realm: Realm!
    var category: Category = Category()
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var itemDescripField: UITextView!
    @IBOutlet weak var importImageButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePickerController = UIImagePickerController()
    var imageNames = [String]()
    // This bool is used to detect when the back button is tapped in the navigation controller
    var goingForwards: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemDescripField.delegate = self
        realm = try! Realm()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        imagePickerController.delegate = self
        
        let actionPopUp = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionPopUp.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            // I used a this resource https://www.andrewcbancroft.com/2018/02/24/swift-cheat-sheet-for-iphone-camera-access-usage/
            // to help out when a user decides not to allow access and then try's to access the camera. It leads them to their settins
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraStatus {
                case .notDetermined: self.requestCameraPermission()
                case .authorized: self.presentCamera()
                case .restricted, .denied: self.cameraAccessNeeded()
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
        // We set it to true because were leaving the current view controller and going forward to the imagePicker(Photo Library)
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
        
        // To-Do: 1) Resize the image 2) Write the image to Disk 3) Store URL to Realm(DB)
        let resizeImage = image.resizeAndCrop(to: 1000)
        guard let url = try? FileService.write(image: resizeImage) else { return }
        // temporarely append the urlString 
        imageNames.append(url)
        collectionView.reloadData()
        // set the bool back to false because were returning to the view controller and dismmissing from the imagePicker(Photo Library)
        goingForwards = false
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController.dismiss(animated: true, completion: nil)
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

        // To-Do: Add URL to Realm
        for imageName in imageNames {
            item.imageNames.append(imageName)
        }
        
        // Do not add an item without a name
        if !item.name.isEmpty {
            try! self.realm.write {
                self.realm.add(item)
            }
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        itemDescripField.text = ""
    }

}

extension AddItemVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let image = try? FileService.readImage(from: imageNames[indexPath.row])
        cell.imgView.image = image
        
        return cell
    }
    
    
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
}

extension UIImage {
    //resizes images to its current size
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resizeAndCrop(to square: CGFloat)-> UIImage {
        let targetSize = CGSize(width: square, height: square)
        return UIGraphicsImageRenderer(size: targetSize).image { context in
            if self.size.width > self.size.height {
                let offset = (self.size.width - self.size.height) / 2
                self.draw(in: CGRect(origin: CGPoint(x: -offset, y: 0), size: size))
            } else {
                let offset = (self.size.height - self.size.width) / 2
                self.draw(in: CGRect(origin: CGPoint(x: 0, y: -offset), size: size))
            }
        }
    }
}
