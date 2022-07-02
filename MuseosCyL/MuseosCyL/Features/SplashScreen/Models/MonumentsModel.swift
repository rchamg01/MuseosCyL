//
//  MonumentsModel.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 11/10/2021.
//

import Foundation
import Alamofire
import CoreData
import UIKit

class MonumentsModel {

    var session = Session.default
    static let shared = MonumentsModel()
    var monumentos = [MonumentsList]()
    
    func requestData(onSuccess success: @escaping ([MonumentsList]) -> Void,
                     onFail fail: @escaping () -> Void) {
        if let url = Bundle.main.url(forResource: "data1", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                monumentos = try decoder.decode([MonumentsList].self, from: jsonData)
                success(monumentos)
            } catch {
                fatalError("Unable to load data")
            }
        } else {
            fail()
        }
    }
    
    func showAlert(vc: UIViewController ,title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
}
