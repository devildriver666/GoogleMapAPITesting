//
//  Endpoint.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation

protocol Endpoint {
    
    var base: String { get }
    var path: String { get }
}

extension Endpoint {
    
    var request: String {
        return base + path
    }
}

enum PorterFeed {
    
    case serviceabilityUrl
    case costUrl
    case etaUrl
}

extension PorterFeed: Endpoint {
    
    var base: String {
        return "https://assignment-mobileapi.porter.in"
    }
    
    var path: String {
        switch self {
        case .serviceabilityUrl: return "/users/serviceability"
        case .costUrl: return "/vehicles/cost"
        case .etaUrl: return "/vehicles/eta"
        }
    }
}








