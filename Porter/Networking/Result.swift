//
//  Result.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation

enum Result <T>{
    case success(T)
    case error(HomeBitApiError,String,Int)
}

enum HomeBitApiError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case invalidURL
    case jsonParsingFailure
}
