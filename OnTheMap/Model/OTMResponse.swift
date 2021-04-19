//
//  OTMResponse.swift
//  OnTheMap
//
//  Created by vagelis spirou on 29/3/21.
//

import Foundation

struct OTMResponse: Codable {
    
    struct Account: Codable {
        let registered: Bool
        let key: String
    }
    
    struct Session: Codable {
        let id: String
        let expiration: String
    }
    
    let account: Account
    let session: Session
    
}
