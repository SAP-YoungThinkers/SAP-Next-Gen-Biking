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
    
    func generateJSON(points: [TrackPoint]) -> [String: Any] {
        
        var jsonObject: [String: Array] = [
            "trackPoints" : [
                // here comes the boom
            ]
        ]
        
        points.forEach { jsonObject["trackPoints"]?.append([$0.latitude, $0.longitude, $0.timestamp]) }
        
        return jsonObject
        
    }
    
    func generateJSONString(JSONObj: [String: Any]) -> NSString {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: JSONObj)
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            return string!
        } catch {
            print("Stringify crashed")
        }
        return ""
    }
    
    
    //MARK: Cloud Storage
    
    func uploadToHana(scriptName: String, paramDict: [String: String]?, jsonData: [String: Any]?) {
        
        let baseUrl = "https://h04-d00.ucc.ovgu.de/gbi-student-042/"
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
            print(response ?? "no response")
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error jsoning")
                    return
                }
                print(todo)
                
            } catch {
                print("error converting")
                return
            }
            }.resume()
        
    }
}
