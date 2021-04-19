//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by vagelis spirou on 30/3/21.
//

import Foundation

struct StudentInformation: Codable {
    
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String?
    let updatedAt: String
    
}
