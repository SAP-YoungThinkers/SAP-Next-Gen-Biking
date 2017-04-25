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
    
    static func clearCollectedGPS() {
        do {
            try FileManager.default.removeItem(atPath: TrackPoint.ArchiveURL.path)
        } catch {
            print(error)
        }
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
    
    static func updateLocalRouteKeys(routeIDs: [Int]){
        var allKeys = routeIDs
        if let loadedKeys = NSKeyedUnarchiver.unarchiveObject(withFile: RouteKeys.ArchiveURL.path) as? [Int] {
            allKeys.append(contentsOf: loadedKeys)
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(allKeys , toFile: RouteKeys.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Error while saving keys locally")
        }
        
    }
    
    
    //MARK: Helper functions for working with JSON
    
    static func generateJSON(tracks: [[TrackPoint]]) -> [String: Any] {
        //tracks is an array consisting of arrays consisting of TrackPoints
        var jsonObject = [
            "tracks" : [[TrackPoint]]()
        ]
        var index = -1 // needed because currentTrack isn't the right index when skipped empty routes
        
        for currentTrack in 0...tracks.count-1 {
            if tracks[currentTrack].isEmpty { continue } // modify condition if you want to eliminate too short tracks
            index += 1
            
            jsonObject["tracks"]?.append([TrackPoint]())  //new empty element
            
            for current in  tracks[currentTrack]{
                
                let location = CLLocationCoordinate2D(latitude: current.latitude, longitude: current.longitude)
                let tp = TrackPoint(point: location, timestamp: current.timestamp)
                
                jsonObject["tracks"]?[index].append(tp)
                
            }
            
        }
        
        return jsonObject
    }
    
    
    //TODO: make it stable
    static func generateJSONString(JSONObj: [String: Any]) -> NSString {
        
        print(JSONObj)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: JSONObj)
            guard let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                return ""
            }
            return string
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
        guard let header = ret["response"] as? HTTPURLResponse else {
            print("Something went wrong")
            return nil
        }
        
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
        
        let loginString = NSString(format: "%@:%@", config.hanaUser, config.hanaPW)
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
            let tracks = jsonData!["tracks"] as! [[TrackPoint]]
            
            var content = [[[String: Any]]]()
            for track in tracks {
                var jsonList = [[String: Any]]()
                for entry in track {
                    let jsonEntry = entry.dictionary()
                    jsonList.append(jsonEntry)
                }
                content.append(jsonList)
            }
            
            let jsonBody: [String: Any] = ["tracks": content]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
            } catch {
                print("invalid JSON")
            }
        }
        let session = URLSession.shared
        
        
        
        //basic template of how communication with a server works
        session.dataTask(with: request) {data, response, err in  //completion handler
            
            guard let responseText = response else {
                
                print("empty response")
                return
            }
            
            print(responseText)
            
            guard let responseData = data else{
                print("nothing")
                return
            }
           
            print(responseData)
            
            do {
                let jsonBody = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                
                if let code = jsonBody?["code"] {
                    if code as? Int == 201{  //upload successful
                        
                        if let keys = jsonBody?["keys"] as? [Int] {
                            updateLocalRouteKeys(routeIDs: keys)
                            clearCollectedGPS()
                        }
                    }
                    else {
                        print("Return code: " + (code as! String))
                    }
                }
                
            } catch {
                print("The following error occured: ")
                print(error)
                return
            }
            
            }.resume()   //very important with urlsession
        
    }
}
