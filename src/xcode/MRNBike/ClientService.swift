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
}

class ClientService {
    
    static func getReports(completion: @escaping ([String: AnyObject])->()) {

        let session = SessionFactory.shared().getSession()
        let request = generateRequest(scriptName: "report/queryReport.xsjs", httpMethod: "GET")

        session.dataTask(with: request) {data, response, error in
            var json = [String: AnyObject]()
            
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
                completion(json)
            } catch {
                print("error serializing JSON: \(error)")
            }
            }.resume()
    }
    
    //ToDo: How this method should look/work? It shouldn't be async, because i need the token for the primary request.
    static func getXCSRFToken() -> String? {
        
        var token: String
        var ret: [String: Any] = [:]
        
        let session = SessionFactory.shared().getSession()
        let request = generateRequest(scriptName: "helper/getToken.xsjs", httpMethod: "GET")
        
        session.dataTask(with: request) { data, response, error in
            if error != nil{
                print("Error -> \(error!)")
                return
            }
            ret["response"] = response!
        }.resume()
        
        guard let header = ret["response"] as? HTTPURLResponse else {
            print("Something went wrong")
            return nil
        }
        
        token = header.allHeaderFields["X-Csrf-Token"] as! String
        
        return token
    }
    
    
    
    static func fetchXCSRFToken(completion: @escaping((String?, ClientServiceError?) -> ())) {
        
        let session = SessionFactory.shared().getSession()
        let request = generateRequest(scriptName: "helper/getToken.xsjs", httpMethod: "GET")
        
        session.dataTask(with: request) { data, response, error in
            if error != nil{
                print("Error -> \(error!)")
                completion(nil,ClientServiceError.httpError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("httpresponse isn't correct!")
                return
            }
            
            
            
            guard let csrfToken = httpResponse.allHeaderFields["X-Csrf-Token"] as? String else {
                
                print("Strnage! CSRF Token is nil")
                completion(nil, ClientServiceError.csrfTokenError)
                return
            }
            completion(csrfToken, nil)
            
            }.resume()
    }
    
    
    static func generateRequest(scriptName: String, httpMethod: String) -> URLRequest {

        let configurator = Configurator()
        
        let loginString = NSString(format: "%@:%@", "GBI_030", "[MobileApp]")
        let loginData = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString()
        let url: URL = URL(string: configurator.backendBaseURL + scriptName)!
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        if httpMethod == "POST" {
            let token = getXCSRFToken()
            if token != nil {
                request.addValue(token!, forHTTPHeaderField: "X-Csrf-Token")
            }
        } else {
            request.setValue("Fetch", forHTTPHeaderField: "X-Csrf-Token")
        }

        return request
    }
}
