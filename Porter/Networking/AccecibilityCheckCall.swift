//
//  AccecibilityCheckCall.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation

class AccecibilityCheckCall: NSObject {
    
    var callCompletion : ((Bool,String) -> Void) = { _,_ in }
    //accecibility get call.
    public func checkAccecibility( ) {
        let getParamUrl = PorterFeed.serviceabilityUrl.request
        NetworkManager.sharedManager.jsonDownloader(getParamUrl, parameters: nil, method: .get) { (result) in
            switch result {
            case .error(  _,let message,_):
                self.callCompletion(false,message)
                return
            case .success(let json):
                guard let dictionary = json as? Dictionary<String,Any> else {
                    self.callCompletion(false,"NO_DATA")
                    return
                }
                if let service = dictionary["serviceable"] as? Bool {
                    if service {
                        self.callCompletion(true, "accecibility_is_on")
                    } else {
                        self.callCompletion(false, "accecibility_is_off")
                    }
                }
            }
        }
    }
}
