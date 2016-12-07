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
    

}
