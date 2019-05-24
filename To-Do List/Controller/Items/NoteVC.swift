//
//  NoteVC.swift
//  To-Do List
//
//  Created by Edgar Delgado on 5/23/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import UIKit

class NoteVC: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.topItem?.titleView = setTitle(title: "Notes", subtitle: "Subtitle")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.setNeedsStatusBarAppearanceUpdate()
    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
    
    // https://stackoverflow.com/questions/38626004/add-subtitle-under-the-title-in-navigation-bar-controller-in-xcode
    func setTitle(title: String, subtitle: String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDifference = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        // if titleLabel is longer than subtitleLabel
        if widthDifference < 0 {
            let newX = widthDifference / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDifference / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }

    @IBAction func dismissModalViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
