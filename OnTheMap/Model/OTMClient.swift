//
//  OTMClient.swift
//  OnTheMap
//
//  Created by vagelis spirou on 29/3/21.
//

import Foundation

class OTMClient {
    
    struct Auth {
        static var userId = ""
        static var objectId = ""
        static var createdAt = ""
        static var firstName = ""
        static var lastName = ""
    }
    
    enum Endpoints {
        case login
        case getStudentLocations
        case postStudentLocation
        case getPublicUserData
        case logout
        
        var stringValue: String {
            switch self {
            case .login:
                return "https://onthemap-api.udacity.com/v1/session"
            case .getStudentLocations:
                return "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=100"
            case .postStudentLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation"
            case .getPublicUserData:
                return "https://onthemap-api.udacity.com/v1/users/\(Auth.userId)"
            case .logout:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPublicUserData(completion: @escaping (Bool, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: Endpoints.getPublicUserData.url) { (data, response, error) in
            guard let data = data else {
                
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            
            do {
                let objectResponse = try decoder.decode(User.self, from: newData)
                Auth.firstName = objectResponse.firstName
                Auth.lastName = objectResponse.lastName
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func postStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.postStudentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            guard let data = data else {
                
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let responseObject = try decoder.decode(OTMPostLocationResult.self
                                                        , from: data)
                Auth.createdAt = responseObject.createdAt
                Auth.objectId = responseObject.objectId
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func getStudentLocation(completion: @escaping ([StudentInformation], Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: Endpoints.getStudentLocations.url) { (data, response, error) in
            guard let data = data else {
                
                DispatchQueue.main.async {
                    completion([], error)
                }
    
                return
                
            }
            
            let decoder = JSONDecoder()
            
            do {
                let objectResponse = try decoder.decode(OTMStudentLocationResults.self, from: data)
                
                DispatchQueue.main.async {
                    completion(objectResponse.results, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
                
            }
        }
        
        task.resume()
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                
                DispatchQueue.main.async {
                    
                    completion(false, error)
                    
                }
                
                return
            }
            
            guard let data = data else {
                
                DispatchQueue.main.async {
                    completion(false, error)
                }
                
                return
                
            }
            
            let range: Range = 5..<data.count
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(OTMResponse.self, from: newData)
                
                Auth.userId = responseObject.account.key
            
                DispatchQueue.main.async {
                    completion(true, nil)
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func logout(completion: @escaping () -> Void) {
        
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil {
              return
          }
          
            Auth.createdAt = ""
            Auth.firstName = ""
            Auth.lastName = ""
            Auth.objectId = ""
            Auth.userId = ""
            completion()
        }
        task.resume()
    }
}
