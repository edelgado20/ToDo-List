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
    
    func getCategories(completion: @escaping (Result<[Category]>) -> Void) {
        AF.request("https://api.fusionofideas.com/todo/getCategories.php").validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let container = try JSONDecoder().decode(CategoryContainer.self, from: data)
                    completion(.success(container.content))
                } catch(let error) {
                    return completion(.failure(error))
                }
                
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    
    func getItems(completion: @escaping (Result<[Item]>) -> Void) {
        AF.request("https://api.fusionofideas.com/todo/getItems.php").validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let container = try JSONDecoder().decode(ItemContainer.self, from: data)
                    //dump(container)
                    completion(.success(container.content))
                } catch(let error) {
                    return completion(.failure(error))
                }
                
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    
    /*func addCategory(name: String) {
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
     
    }*/
    
}
