

import Foundation
import UIKit
import CoreLocation

class StorageHelper : NSObject {
    
    static let config = Configurator()
    static let dpqueue = DispatchQueue(label: "com.MRNBike.dpqueue")
    
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
        
        let config = URLSessionConfiguration.default
        
        
        let session = URLSession(configuration: config, delegate: nil, delegateQueue:OperationQueue.main)
        
        // let session = URLSession.shared
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
    static func getToken(authorization: String) -> String? {
        
        var token: String?
        
        let url: URL = URL(string: config.backendBaseURL + "helper/getToken.xsjs")!
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
    
    //Prepare the request to get reports from backend
    static func prepareRequest(scriptName: String) -> [String: AnyObject] {
        let loginString = NSString(format: "%@:%@", config.hanaUser, config.hanaPW)
        let loginData = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString()
        
        let url:URL = URL(string: config.backendBaseURL + scriptName)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Fetch", forHTTPHeaderField: "X-Csrf-Token")
        
        var test = [String: AnyObject]()
        
        makeRequest(request: request) {response in
            test = response
        }
        
        
        return test
    }
    
    //Make request to get reports from backend
    static func makeRequest(request: URLRequest, completion: @escaping ([String: AnyObject])->()) {
        
        var json = [String: AnyObject]()
        //TODO: create a session factory in order to distribute the shared session to other classes.
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue:OperationQueue.main)
        
        session.dataTask(with: request) {data, response, error in
            do {
                json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
                completion(json)
            } catch {
                print("error serializing JSON: \(error)")
            }
            }.resume()
        
    }
}
