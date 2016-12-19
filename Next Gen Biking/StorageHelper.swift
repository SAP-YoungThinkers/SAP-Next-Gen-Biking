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
    
    func uploadToHana(points: [TrackPoint]) -> Bool {
        
        // Preparing HTTP Post
        
            /* ToDo: insert code */
        
        // Sending Data
        
            /* ToDo: insert code */
        
        // Exploiting server's response:
        
        let response = 201 // ToDo: insert callback
        if response == 201 /* ToDo: insert condition */{
            return true
        } else {
            return false    /* Ignore this waring. It will disappear, once
                             * if you have inserted the funtion calls
                             */
        }
    }
    
    
    // TODO: implement SSL
    
    func upload_request(scriptName: String, paramDict: [String: String]) {
        
        let baseUrl = "https://h04-d00.ucc.ovgu.de/gbi-student-042/"
        
        // building the full URL for the REST call
        var fullUrl: String = baseUrl + scriptName + "?"
        for (key, value) in paramDict {
            if fullUrl.characters.last != "?" {
                fullUrl.append("&")
            }
            fullUrl += key + "=" + value
        }
        
        let url:URL = URL(string: fullUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            //Insert completion handler code
            }.resume()
        
        
    
    }
    
    static func restTest() {
        let link: String = "https://jsonplaceholder.typicode.com/todos/1"
        
        
        let url = URL(string: link)!
        
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        _ = session.dataTask(with: request) {data, response, err in
            
            guard err == nil else {
                print(err!)
                return
            }
            guard let responseData = data else{
                print("did not receive data")
                return
            }
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
