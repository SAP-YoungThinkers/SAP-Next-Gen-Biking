//
//  ClientService.swift
//  MRNBike
//
//  Created by Bartosz Wilkusz on 28.06.17.
//
//

import Foundation

enum ClientServiceError: Error {
    case httpError
    case csrfTokenError
    case jsonSerializationError
}

class ClientService {
    
    static let config = Configurator()
    
    //Create, edit or verify a user on backend (Hana)
    static func postUser(scriptName: String, userData: Data, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: scriptName, httpMethod: "POST", data : userData, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard (response as? HTTPURLResponse) != nil else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    guard let responseData = data else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    do {
                        let jsonBody = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        
                        guard let code = jsonBody?["code"] as? Int else {
                            completion(nil, ClientServiceError.httpError)
                            return
                        }
                        completion(code, nil)
                        
                    } catch {
                        completion(nil, ClientServiceError.jsonSerializationError)
                    }
                    }.resume()
                
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Upload report to backend (Hana)
    static func uploadReportToHana(reportInfo: Data, completion: @escaping (ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: "report/createReport.xsjs", httpMethod: "POST", data : reportInfo, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard (response as? HTTPURLResponse) != nil else {
                        completion(ClientServiceError.httpError)
                        return
                    }
                    
                    guard let responseData = data else {
                        completion(ClientServiceError.httpError)
                        return
                    }
                    
                    do {
                        let jsonBody = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        
                        if let code = jsonBody?["code"] {
                            if code as? Int == 201 {
                                completion(nil)
                            }
                            else {
                                completion(ClientServiceError.httpError)
                            }
                        }
                        
                    } catch {
                        completion(ClientServiceError.jsonSerializationError)
                    }
                    }.resume()
                
            } else {
                completion(error)
            }
        }
    }
    
    //Get all reports from backend (Hana)
    static func getReports(completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: "report/queryReport.xsjs", httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    var json = [String: AnyObject]()
                    
                    do {
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
                        completion(json, nil)
                    } catch {
                        completion(nil, ClientServiceError.jsonSerializationError)
                    }
                    
                    }.resume()
                
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Upload route to backend (Hana)
    static func uploadRouteToHana(route: [String: Any], completion: @escaping (Int?, [Int]?, ClientServiceError?)->()) {
        
        let tracks = route["tracks"] as! [[TrackPoint]]
        
        var content = [[[String: Any]]]()
        for track in tracks {
            var jsonList = [[String: Any]]()
            for entry in track {
                let jsonEntry = entry.dictionary()
                jsonList.append(jsonEntry)
            }
            content.append(jsonList)
        }
        
        let session = SessionFactory.shared().getSession()
        
        let routeData: [String: Any] = ["tracks": content]
        
        generateRequest(scriptName: "importData/bringItToHana.xsjs", httpMethod: "POST", data: nil, route: routeData) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard (response as? HTTPURLResponse) != nil else {
                        completion(nil, nil, ClientServiceError.httpError)
                        return
                    }
                    
                    guard let responseData = data else {
                        completion(nil, nil, ClientServiceError.httpError)
                        return
                    }
                    
                    do {
                        let jsonBody = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        
                        guard let code = jsonBody?["code"] as? Int else {
                            completion(nil, nil, ClientServiceError.httpError)
                            return
                        }
                        
                        guard let keys = jsonBody?["keys"] as? [Int] else {
                            completion(nil, nil, ClientServiceError.httpError)
                            return
                        }
                        
                        completion(code, keys, nil)
                    } catch {
                        completion(nil, nil, ClientServiceError.jsonSerializationError)
                    }
                    }.resume()
                
            } else {
                completion(nil, nil, error)
            }
        }
    }
    
    static func fetchXCSRFToken(completion: @escaping((String?, ClientServiceError?) -> ())) {
        
        let session = SessionFactory.shared().getSession()
        generateRequest(scriptName: "helper/getToken.xsjs", httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) { data, response, error in
                    
                    if error != nil{
                        completion(nil,ClientServiceError.httpError)
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(nil,ClientServiceError.httpError)
                        return
                    }
                    
                    guard let csrfToken = httpResponse.allHeaderFields["x-csrf-token"] as? String else {
                        completion(nil, ClientServiceError.csrfTokenError)
                        return
                    }
                    
                    completion(csrfToken, nil)
                    
                    }.resume()
                
            } else {
                completion(nil, error)
            }
        }
    }
    
    static func generateRequest(scriptName: String, httpMethod: String, data: Data?, route: [String: Any]?, completion: @escaping((URLRequest?, ClientServiceError?) -> ())) {
        
        let configurator = Configurator()
        
        let loginString = NSString(format: "%@:%@", config.hanaUser, config.hanaPW)
        let loginData = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString()
        let url: URL = URL(string: configurator.backendBaseURL + scriptName)!
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        
        if httpMethod == "GET" {
            request.setValue("Fetch", forHTTPHeaderField: "X-Csrf-Token")
        }
        
        if httpMethod == "POST" {
            
            fetchXCSRFToken(completion: { (token, error) in
                if error == nil {
                    request.addValue(token!, forHTTPHeaderField: "X-Csrf-Token")
                    
                    if data != nil {
                        request.httpBody = data
                    } else {
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: route!)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    }
                    
                    completion(request, nil)
                    
                } else {
                    completion(nil, ClientServiceError.csrfTokenError)
                }
            })
            
        } else {
            completion(request, nil)
        }
    }
}
