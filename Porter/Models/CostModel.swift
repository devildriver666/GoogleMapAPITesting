//
//  CostModel.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation

struct CostModel {
    
    var cost:Int?
}

extension CostModel {
    
    struct Key {
        static let cost = "cost"
    }
    // json parsing to create model
    init?(json: [String: AnyObject]) {
        //parsing
        print(json)
        self.cost = json[Key.cost] as? Int ?? 0
        return
    }
}
