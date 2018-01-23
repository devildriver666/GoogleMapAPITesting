//
//  MapModel.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation

struct EtaModel {
    
    var eta:Int?
}

extension EtaModel {
    
    struct Key {
        static let eta = "eta"
    }
    // json parsing to create model
    init?(json: [String: AnyObject]) {
        //parsing
        print(json)
        self.eta = json[Key.eta] as? Int ?? 0
        return
    }
}
