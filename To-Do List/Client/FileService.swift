//
//  FileService.swift
//  To-Do List
//
//  Created by Edgar Delgado on 4/6/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.

/*  This file is used to write/read/delete images into the Documents folder of the file system */

import UIKit

enum FileService {
    static func write(image: UIImage, to filename: String = UUID().uuidString) throws -> String {
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent(filename)
        guard let data = image.pngData() else { throw FileServiceError.noData }
        print("Write to Disk")
        try data.write(to: fileURL)
        return filename
    }
    
    static func readImage(from filename: String) throws -> UIImage? {
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent(filename)
        let data = try Data(contentsOf: fileURL)
        print("Read Image")
        return UIImage.init(data: data)
    }
    
    static func delete(filename: String) throws {
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent(filename)
        try FileManager.default.removeItem(at: fileURL)
        print("Deleted Image from Disk/Documents")
    }
}

enum FileServiceError: Error {
    case noData
}
