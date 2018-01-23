//
//  MapViewModel.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation

class MapViewModel: NSObject {
    
    var callCompletion : ((Bool,String) -> Void) = { _,_ in }
    
    //call back when view model is ready.
    var costTimeEstimation:String? {
        didSet {
             callCompletion(true,"GOT_DATA")
        }
    }
    
    //Lat Long dependency property injection
    var lat:Double?
    var lng:Double?
    var param:[String: AnyObject]?
    
    var etaModel:EtaModel?
    var costModel:CostModel?
    
    //Group Asyn calls
    let dispatchGroup = DispatchGroup()
    
    //ETA API call
    public func getEta( ) {
        //Url Creation
        let getParamUrl = PorterFeed.etaUrl.request + "?lat=\(String(describing: lat!))&lng=\(String(describing: lng!))"
        NetworkManager.sharedManager.jsonDownloader(getParamUrl, parameters: param, method: .get) { [unowned self] (result) in
            switch result {
            case .error(  _,let message,_):
                self.callCompletion(false,message)
                return
            case .success(let json):
                guard let dictionary = json as? Dictionary<String,Any> else {
                    self.callCompletion(false,"NO_DATA")
                    return
                }
                self.etaModel = EtaModel(json: dictionary as [String : AnyObject])
                self.dispatchGroup.leave()
            }
        }
    }
    
    //Cost API call
    public func getCost( ) {
        let getParamUrl = PorterFeed.costUrl.request + "?lat=\(String(describing: lat!))&lng=\(String(describing: lng!))"
        NetworkManager.sharedManager.jsonDownloader(getParamUrl, parameters: param, method: .get) {  [unowned self] (result) in
            switch result {
            case .error(  _,let message,_):
                self.callCompletion(false,message)
                return
            case .success(let json):
                guard let dictionary = json as? Dictionary<String,Any> else {
                    self.callCompletion(false,"NO_DATA")
                    return
                }
                self.costModel = CostModel(json: dictionary as [String : AnyObject])
                self.dispatchGroup.leave()
            }
        }
    }
    
    //public function to fetch data with group call using GCD
    public func fetchData() {
        //Call Eta
        dispatchGroup.enter()
        getEta()
        //Call Cost
        dispatchGroup.enter()
        getCost()
        //Wait for both calls to finish
        dispatchGroup.notify(queue: .main) {[unowned self] in
            if let cost = self.costModel?.cost, let etaValue = self.etaModel?.eta {
                //set view model.
               self.costTimeEstimation = "₹ \(String(describing: cost))  •  \(String(describing: etaValue)) mins"
            } else {
                 self.callCompletion(false,"NO_DATA")
            }
        }
    }
}
