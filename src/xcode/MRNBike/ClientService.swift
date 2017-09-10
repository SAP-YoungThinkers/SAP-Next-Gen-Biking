import Foundation

enum ClientServiceError: Error {
    case httpError
    case csrfTokenError
    case jsonSerializationError
    case notFound
}

class ClientService {
    
    static let config = Configurator()
    
    //Create, update and add friends to group on backend
    //Create: createGroup.xsjs
    //Edit: updateGroupInfo.xsjs
    //AddFriends: addFriendsToGroup.xsjs
    static func postGroup(scriptName: String, groupData: Data, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: scriptName, httpMethod: "POST", data : groupData, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    completion(status, nil)
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Get group list for a user from backend
    static func getGroupList(mail: String, completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        let scriptName = "getGroups.xsjs?email=" + mail
        
        generateRequest(scriptName: scriptName, httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    switch status {
                    case 200:
                        guard let responseData = data else {
                            completion(nil, ClientServiceError.httpError)
                            return
                        }
                        
                        var json = [String: AnyObject]()
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments) as! [String: AnyObject]
                            completion(json, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    case 404:
                        completion(nil, ClientServiceError.notFound)
                        return
                    default:
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
        
    }
    
    //Delete user from group
    static func deleteUserFromGroup(userId: String, groupId: String, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        let scriptName = "deleteUserFromGroup.xsjs?groupId=" + groupId + "&userID=" + userId
        
        generateRequest(scriptName: scriptName, httpMethod: "DELETE", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    completion(status, nil)
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Delete group
    static func deleteGroup(groupId: String, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        let scriptName = "deleteGroup.xsjs?groupId=" + groupId
        
        generateRequest(scriptName: scriptName, httpMethod: "DELETE", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    completion(status, nil)
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Send friend request to another user: sendFriendRequest.xsjs
    //Answer friend request: answerFriendRequest.xsjs
    static func postFriendRequest(scriptName: String, relationship: Data, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: scriptName, httpMethod: "POST", data : relationship, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    completion(status, nil)
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }

    //Get friendlist of a user from backend
    static func getFriendList(mail: String, completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        let scriptName = "getFriendList.xsjs?userId=" + mail
        
        generateRequest(scriptName: scriptName, httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    switch status {
                    case 200:
                        guard let responseData = data else {
                            completion(nil, ClientServiceError.httpError)
                            return
                        }
                        
                        var json = [String: AnyObject]()
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments) as! [String: AnyObject]
                            completion(json, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    case 404:
                        completion(nil, ClientServiceError.notFound)
                        return
                    default:
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
        
    }
    
    //Delete friendship
    static func deleteFriend(userId: String, friendId: String, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        let scriptName = "deleteFriend.xsjs?userId=" + userId + "&friendId=" + friendId
        
        generateRequest(scriptName: scriptName, httpMethod: "DELETE", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    completion(status, nil)
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }

    //Create, edit or verify a user on backend
    //Create: createUser.xsjs
    //Edit: updateUser.xsjs
    //Verify: verifyUser.xsjs
    static func postUser(scriptName: String, userData: Data, completion: @escaping (Int?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: scriptName, httpMethod: "POST", data : userData, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    completion(status, nil)
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Get user from backend
    static func getUser(mail: String, completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        let scriptName = "readUser.xsjs?email=" + mail
        
        generateRequest(scriptName: scriptName, httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    if status == 200 {
                        guard let responseData = data else {
                            completion(nil, ClientServiceError.httpError)
                            return
                        }
                        
                        var json = [String: AnyObject]()
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments) as! [String: AnyObject]
                            completion(json, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    } else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    }.resume()
                
            } else {
                completion(nil, error)
            }
        }
        
    }
    
    //Upload report to backend
    static func uploadReportToHana(reportInfo: Data, completion: @escaping (ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: "createReport.xsjs", httpMethod: "POST", data : reportInfo, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(ClientServiceError.httpError)
                        return
                    }
                    
                    if status == 200 {
                       completion(nil)
                    } else {
                        completion(ClientServiceError.httpError)
                        return
                    }
                    
                    }.resume()
            } else {
                completion(error)
            }
        }
    }
    
    //Get all reports from backend
    static func getReports(completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: "queryReport.xsjs", httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    if status == 200 {
                        
                        guard let responseData = data else {
                            completion(nil, ClientServiceError.httpError)
                            return
                        }
                        
                        var json = [String: AnyObject]()
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
                            completion(json, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    } else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }

                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Upload route to backend
    static func uploadRouteToHana(route: [String: Any], statistics: [[String: Any]], completion: @escaping ([Int]?, ClientServiceError?)->()) {
        
        let tracks = route["tracks"] as! [[TrackPoint]]
        
        var statsContent = [[String: Any]]()
        var content = [[[String: Any]]]()
        
        for (index, track) in tracks.enumerated() {
            var jsonList = [[String: Any]]()
            for entry in track {
                let jsonEntry = entry.dictionary()
                jsonList.append(jsonEntry)
            }
            content.append(jsonList)
            statsContent.append(statistics[index])
        }
        
        /*
 
            Because of statistics, we will upload body containing the route json, followed by seperator:
            ###
            and then followed by statistics json
         
         */
        
        let session = SessionFactory.shared().getSession()
        
        let routeData: [String: Any] = ["tracks": content]
        var tmpRouteData : Data = Data()
        
        do {
            tmpRouteData = try JSONSerialization.data(withJSONObject: routeData)
            tmpRouteData.append("###".data(using: .utf8)!)
            let statsData = [
                "statistics" : statsContent
            ]
            let appendData = try JSONSerialization.data(withJSONObject: statsData)
            tmpRouteData.append(appendData)
        } catch {
            // other way
        }
        
        print(String.init(data: tmpRouteData, encoding: String.Encoding.utf8) ?? "empty")
        
        generateRequest(scriptName: "saveRouteTest.xsjs", httpMethod: "POST", data: tmpRouteData, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    if status == 200 {
                        
                        guard let responseData = data else {
                            completion(nil, ClientServiceError.httpError)
                            return
                        }
                        
                        do {
                            let jsonBody = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                            
                            guard let keys = jsonBody?["id"] as? [Int] else {
                                completion(nil, ClientServiceError.httpError)
                                return
                            }
                            
                            completion(keys, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    } else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }

                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Get routes from backend
    static func getRoutes(routeKeys: Data,completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: "queryRoutes.xsjs", httpMethod: "POST", data: routeKeys, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    if status == 200 {
                        var json = [String: AnyObject]()
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
                            completion(json, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    } else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }

    //Get statistics from backend
    static func getRouteInfos(routeKeys: Data,completion: @escaping ([String: AnyObject]?, ClientServiceError?)->()) {
        
        let session = SessionFactory.shared().getSession()
        
        generateRequest(scriptName: "get4WeeksStatistics.xsjs", httpMethod: "POST", data: routeKeys, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) {data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    if status == 200 {
                        var json = [String: AnyObject]()
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
                            completion(json, nil)
                        } catch {
                            completion(nil, ClientServiceError.jsonSerializationError)
                        }
                    } else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                    
                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Get xcsdf-token for post requests
    static func fetchXCSRFToken(completion: @escaping((String?, ClientServiceError?) -> ())) {
        
        let session = SessionFactory.shared().getSession()
        generateRequest(scriptName: "helper/getToken.xsjs", httpMethod: "GET", data: nil, route: nil) { (urlRequest, error) in
            
            if error == nil {
                
                session.dataTask(with: urlRequest!) { data, response, error in
                    
                    guard let status = (response as? HTTPURLResponse)?.statusCode else {
                        completion(nil, ClientServiceError.httpError)
                        return
                    }
                   
                    if error == nil && status == 200 {
                        guard let httpResponse = response as? HTTPURLResponse else {
                            completion(nil,ClientServiceError.httpError)
                            return
                        }
                        guard let csrfToken = httpResponse.allHeaderFields["x-csrf-token"] as? String else {
                            completion(nil, ClientServiceError.csrfTokenError)
                            return
                        }
                        completion(csrfToken, nil)
                    } else {
                        completion(nil,ClientServiceError.httpError)
                        return
                    }

                    }.resume()
            } else {
                completion(nil, error)
            }
        }
    }
    
    //Generate the http request with http headers and body
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
        
        if httpMethod != "GET" {
            
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
