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
}
