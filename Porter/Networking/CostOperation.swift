//
//  SessionOperation.swift
//  BajaarPadApplication
//
//  Created by abhijeet upadhyay on 12/01/17.
//  Copyright © 2017 bajaar. All rights reserved.
//

import UIKit
import Alamofire


class CostOperation: Operation {
    
    var completionClosure : ((Bool) -> Void) = { _ in }
    
    override func main() {
        if isCancelled {
            return
        }
    }
    
    //MARK: - Operation calls
    override var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
            print("1")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    fileprivate var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        _executing = true
        execute()
    }
    
    func execute() {
            //call for concierge
            let getParamUrl = APIConstants.sessionApiUrl
        
            NetworkManager.sharedManager.jsonDownloader(getParamUrl, parameters:nil , method: .get) { (result) in
                switch result {
                case .error( _,_,_):
                    self.completionClosure(false)
                    return
                case .success(let json):
                    guard let jsonData = json as? Dictionary<String, AnyObject> else {
                        self.completionClosure(false)
                        return
                    }
                    print("I am here \(jsonData)")
                    if let paymentJson = jsonData["payment"] as? [String: AnyObject] {
                        print("I am here1")
                        if let paymentModel = PaymentModel(json: paymentJson) {
                            ModelSharedManager.sharedInstance.paymentModel = paymentModel
                        } else {
                             ModelSharedManager.sharedInstance.paymentModel = nil
                        }
                    } else {
                        print("I am here2")
                        //need to see what to do here
                        ModelSharedManager.sharedInstance.paymentModel = nil
                    }
                    if let userModel = UserModel(json: jsonData) {
                        ModelSharedManager.sharedInstance.userModel = userModel
                        //parse property data
                        
                        if  let propertyValue = jsonData["properties"] as? NSArray {
                            if propertyValue.count > 0 {
                                let propertyDictionary = propertyValue[propertyValue.count - 1] as! [String: AnyObject]
                                //parsing
                                let homeDataSource = HomeDetailModel(json: propertyDictionary)
                                if homeDataSource != nil {
                                    ModelSharedManager.sharedInstance.homeDetailModel = homeDataSource!
                                    //print(ModelSharedManager.sharedInstance.homeDetailModel)
                                }
                            }
                        }
                        self.completionClosure(true)
                    } else {
                        self.completionClosure(false)
                    }
                }
            }
        }
    
    func finish() {
        // Notify the completion of async task and hence the completion of the operation
        _executing = false
        _finished = true
    }
}
