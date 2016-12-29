//
//  UploadHelper.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 06.12.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import Foundation
import UIKit

class StorageHelper : NSObject {

    // MARK: Local Storage
    
    static func loadGPS() -> [TrackPoint]? {
        
        let firstVC = FirstViewController()
        
        if var loadedGPS = NSKeyedUnarchiver.unarchiveObject(withFile: TrackPoint.ArchiveURL.path) as? [TrackPoint]
        {
            loadedGPS.append(contentsOf: firstVC.getTrackPoints())
            
            if loadedGPS.count < 1 {
                return nil
            }
            return loadedGPS
        }
        
        return nil
    }
    
    
    static func storeLocally(trackPointsArray: [TrackPoint]) -> Bool {
        
        print("Storing \(trackPointsArray.count) points")
        
        var concatenatedData = trackPointsArray
        
        if let localData = loadGPS() {
            concatenatedData.append(contentsOf: localData)
        }
        
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(concatenatedData , toFile: TrackPoint.ArchiveURL.path)
        
        if !isSuccessfulSave {
            return false
        } else {
            return true
        }
    }
    

    //MARK: Helper functions for working with JSON
    
    static func generateJSON(points: [TrackPoint]) -> [String: Any] {
        
        var jsonObject: [String: Array] = [
            "trackPoints" : [
                // here comes the boom
            ]
        ]
        
        points.forEach { jsonObject["trackPoints"]?.append([$0.latitude, $0.longitude, $0.timestamp]) }
        
        return jsonObject
        
    }
    
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
    
    
    static func sendRequest(request: URLRequest) -> [String: Any] {
        let session = URLSession.shared
        var ret: [String: Any] = [:]
        let sem = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil{
                print("Error -> \(error)")
                return
            }
            
            ret["data"] = data!
            ret["response"] = response!
            sem.signal()
        }
        
        task.resume()
        
        // This line will wait until the semaphore has been signaled
        // which will be once the data task has completed
        sem.wait(timeout: .distantFuture)
        
        return ret
    }
    
    //MARK: Cloud Storage
    
    static func getToken(destination: String) -> String? {
        
        var token: String?
        
        let url: URL = URL(string: destination)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Fetch", forHTTPHeaderField: "X-CSRF-Token")
        
        let ret = sendRequest(request: request)
        let header = ret["response"] as! HTTPURLResponse
        token = header.allHeaderFields["x-csrf-token"] as? String
        
        print("token")
        print(token!)
        return token
    }
    
    static func uploadToHana(scriptName: String, paramDict: [String: String]?, jsonData: [String: Any]?) {
        
        let baseUrl = "https://h04-d00.ucc.ovgu.de/gbi-student-042/importData/"
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
        
        let url:URL = URL(string: fullUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let x_csrf_token = getToken(destination: baseUrl + "xsrf.xsjs")
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
        
        session.dataTask(with: request) {data, response, err in
            guard err == nil else {
                print(err!)
                return
            }
            guard let responseData = data else{
                print("did not receive data")
                return
            }
            //print("Data:")
            //print(String(data: data!, encoding: String.Encoding.utf8) ?? "no data")
            //print("Response: ")
            //print(response ?? "no response")
            do {
                guard let responseBody = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error jsoning")
                    return
                }
                //print("Body of response: ")
                //print(responseBody)
                
            } catch {
                print("error converting")
                return
            }
            }.resume()
        
    }
}
