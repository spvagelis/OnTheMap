//
//  User.swift
//  OnTheMap
//
//  Created by vagelis spirou on 8/4/21.
//

import Foundation

struct User: Codable {
    
    let lastName: String
    let firstName: String
    
    enum CodingKeys: String, CodingKey {
        
        case lastName = "last_name"
        case firstName = "first_name"
    }
}
