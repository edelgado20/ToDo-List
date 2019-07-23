//
//  Extensions.swift
//  To-Do List
//
//  Created by COFEBE, inc. on 1/25/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
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
