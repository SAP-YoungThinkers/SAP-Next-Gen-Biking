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
    
    static func uploadReportToHana(reportInfo: Data, completion: @escaping (ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        print("2")
        
        generateRequest(scriptName: "report/createReport.xsjs", httpMethod: "POST", data : reportInfo) { (urlRequest, error) in
            print("4")
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
                            if code as? Int == 201{
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
    
    static func getReports(completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        print("2")
        
        generateRequest(scriptName: "report/queryReport.xsjs", httpMethod: "GET", data: nil) { (urlRequest, error) in
            print("4")
            if error == nil {
                session.dataTask(with: urlRequest!) {data, response, error in
                    print("5")
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
    
    static func fetchXCSRFToken(completion: @escaping((String?, ClientServiceError?) -> ())) {
        
        let session = SessionFactory.shared().getSession()
        generateRequest(scriptName: "helper/getToken.xsjs", httpMethod: "GET", data: nil) { (urlRequest, error) in
            
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
                    
                    guard let csrfToken = httpResponse.allHeaderFields["X-Csrf-Token"] as? String else {
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
    
    static func generateRequest(scriptName: String, httpMethod: String, data: Data?, completion: @escaping((URLRequest?, ClientServiceError?) -> ())) {
        
        print("3")
        
        let configurator = Configurator()
        
        let loginString = NSString(format: "%@:%@", config.hanaUser, config.hanaPW)
        let loginData = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString()
        let url: URL = URL(string: configurator.backendBaseURL + scriptName)!
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        
        if httpMethod == "POST" {
            print("3.1")
            fetchXCSRFToken(completion: { (token, error) in
                if error == nil {
                    request.addValue(token!, forHTTPHeaderField: "X-Csrf-Token")
                    request.httpBody = data
                    completion(request, nil)
                } else {
                    completion(nil, ClientServiceError.csrfTokenError)
                }
                
            })
            
        } else {
            print("3.2")
            completion(request, nil)
            
        }
    }
}
