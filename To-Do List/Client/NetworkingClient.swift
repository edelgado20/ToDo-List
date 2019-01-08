//
//  NetworkingClient.swift
//  To-Do List
//
//  Created by COFEBE, inc. on 1/8/19.
//  Copyright © 2019 Edgar Delgado. All rights reserved.
//

import Foundation
import Alamofire

class NetworkingClient {
    
    func getCategories() {
        AF.request("https://api.fusionofideas.com/todo/getCategories.php").validate().responseJSON { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Result: \(response.result)")

            if let json = response.result.value {
                print("JSON: \(json)")
            }

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
            
        }
    }
    
    func getItems() {
        AF.request("https://api.fusionofideas.com/todo/getItems.php").validate().responseJSON { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Result: \(response.result)")
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
            
        }
    }
    
    func addCategory(name: String) {
        AF.request("https://api.fusionofideas.com/todo/addCategory.php", method: .post, parameters: name).validate().response { response in
            switch response.result {
            case .failure(let err):
                print("error getting together: \(response.data)")
            case .success(_):
                print("success")
            }
        }
    }
    
    func addItem() {
        AF.request("https://api.fusionofideas.com/todo/addItem.php", method: .post)
    }
    
    func updateCategory() {
        
    }
    
    func updateItem() {
        
    }
    
    func deleteCategory(id: Int) {
        AF.request("https://api.fusionofideas.com/todo/deleteCategory.php", method: .delete, parameters: id)
    }
    
    func deleteItem(id: Int) {
        AF.request("https://api.fusionofideas.com/todo/deleteItem.php", method: .delete, parameters: id)
    }
    
}
