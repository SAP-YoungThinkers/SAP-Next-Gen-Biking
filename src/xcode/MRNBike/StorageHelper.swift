//
//  UploadHelper.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 06.12.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class StorageHelper : NSObject {
    
    static let config = Configurator()

    // MARK: Local Storage
    
    static func loadGPS() -> [[TrackPoint]]? {
        
        if let loadedGPS = NSKeyedUnarchiver.unarchiveObject(withFile: TrackPoint.ArchiveURL.path) as? [[TrackPoint]]
        {
            
            if loadedGPS.count < 1 {
                return nil
            }
            return loadedGPS
        }
        
        return nil
    }
    
    
    static func storeLocally(trackPointsArray: [TrackPoint]) -> Bool {
        
        var concatenatedData = [[TrackPoint]]()
        
        if let localData = loadGPS() {
            concatenatedData.append(contentsOf: localData)
        }
        concatenatedData.append(trackPointsArray)

        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(concatenatedData , toFile: TrackPoint.ArchiveURL.path)
        
        if !isSuccessfulSave {
            return false
        } else {
            return true
        }
    }
    

    //MARK: Helper functions for working with JSON
    
    static func generateJSON(tracks: [[TrackPoint]]) -> [String: Any] {
        //tracks is an array consisting of arrays consisting of TrackPoints
        
        var jsonObject = [
            "tracks" : [[TrackPoint]]()
        ]
        
        
        for currentTrack in 0...tracks.count-1 {
            
            jsonObject["tracks"]?.append([TrackPoint]())  //new empty element
            
            for currentPoint in 0...tracks[currentTrack].count-1 {
                let current = tracks[currentTrack][currentPoint]
                
                let location = CLLocationCoordinate2D(latitude: current.latitude, longitude: current.longitude)
                let tp = TrackPoint(point: location, timestamp: current.timestamp)
                
                jsonObject["tracks"]?[currentTrack].append(tp)
                
            }
        
        }
        
        return jsonObject
    }
    
    
    //TODO: make it stable
    static func generateJSONString(JSONObj: [String: Any]) -> NSString {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: JSONObj)
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            return string!
        } catch {
            print("Stringify crashed")
        }
        return ""
    }
    
    
    
    //TODO: asynch without semaphores
    static func sendRequest(request: URLRequest) -> [String: Any] {
        let session = URLSession.shared
        var ret: [String: Any] = [:]
        let sem = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil{
                print("Error -> \(error!)")
                return
            }
            
            ret["data"] = data!
            ret["response"] = response!
            sem.signal()
        }
        
        task.resume()
        
        // This line will wait until the semaphore has been signaled
        // which will be once the data task has completed
        _ = sem.wait(timeout: .distantFuture)
        
        return ret
    }
    
    //MARK: Cloud Storage
    
    static func getToken(destination: String, authorization: String) -> String? {
        
        
        var token: String?
        
        let url: URL = URL(string: destination)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("fetch", forHTTPHeaderField: "x-csrf-token")
        request.addValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
        
        let ret = sendRequest(request: request)
        let header = ret["response"] as! HTTPURLResponse
        token = header.allHeaderFields["x-csrf-token"] as? String

        return token
    }
    
    static func uploadToHana(scriptName: String, paramDict: [String: String]?, jsonData: [String: Any]?) {
        
        let baseUrl = config.backendBaseURL
        var fullUrl: String = baseUrl + scriptName
        
        // building the full URL for the REST call
        if paramDict != nil {
            fullUrl += "?"
            for (key, value) in paramDict! {
                if fullUrl.characters.last != "?" {
                    fullUrl.append("&")
                }
                fullUrl += key + "=" + value
            }
        }

        let loginString = NSString(format: "%@:%@", config.username, config.password)
        let loginData = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString()
        print("Basic \(base64LoginString)")
        
        let url:URL = URL(string: fullUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let x_csrf_token = getToken(destination: baseUrl + scriptName, authorization: base64LoginString)
        if x_csrf_token != nil {
            request.addValue(x_csrf_token!, forHTTPHeaderField: "x-csrf-token")
        }
        
        if jsonData != nil {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonData!)
            } catch {
                print("invalid JSON")
            }
        }
        
        let session = URLSession.shared
        
        
        
        //basic template of how communication with a server works
        session.dataTask(with: request) {data, response, err in  //completion handler
            
            guard err == nil else {
                print(err!)
                return
            }
            guard let responseData = data else{
                print("did not receive data")
                return
            }
            print("Data:")
            print(String(data: responseData, encoding: String.Encoding.utf8) ?? "no data")
            print("Response: ")
            print(response ?? "no response")
            do {
                guard let responseBody = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error jsoning")
                    return
                }
                print("Body of response: ")
                print(responseBody)
                
            } catch {
                print("error converting")
                return
            }
            }.resume()   //very important with urlsession
        
    }
}
