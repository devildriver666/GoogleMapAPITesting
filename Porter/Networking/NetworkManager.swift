//
//  NetworkManager.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
    
    static var sharedManager = NetworkManager()
    
    typealias JSONDictionary = Dictionary<String, AnyObject>
    typealias JSONArray = Array<AnyObject>

    typealias JSONTaskCompletionHandler = (Result<Any>) -> ()
    
    func jsonDownloader(_ strURL: String, parameters: [String: AnyObject]?, method:HTTPMethod ,completion:@escaping JSONTaskCompletionHandler) {
        //If needed configure tokens and headers.
        //Not needed here
    
        //Alamofire REST API call
        Alamofire.request(strURL, method:method, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                //Authorization set up if existing
                
                //Data reading if available and successful
                if response.response?.statusCode == 200 {
                    print("status code\(String(describing: response.response?.statusCode))")
                    if let json = JSON as? Dictionary<String, AnyObject> {
                            DispatchQueue.main.async {
                                completion(.success(json))
                            }
                    } else {
                        DispatchQueue.main.async {
                            completion(.error(.jsonConversionFailure,"Request Failed",(response.response?.statusCode)!))
                        }
                    }
                } else {
                    completion(.error(.requestFailed,"Request Failed",  (response.response?.statusCode)!))
                }
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                DispatchQueue.main.async {
                    completion(.error(.requestFailed,"Request Failed",  -1009))
                }
                break
            }
        }
    }
}



