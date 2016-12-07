//
//  UploadHelper.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 06.12.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import Foundation
import UIKit

class UploadHelper : NSObject {

    // MARK: Local Storage
    
    static func storeLocally(trackPointsArray: [TrackPoint]) -> Bool {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(trackPointsArray, toFile: TrackPoint.ArchiveURL.path)
        
        if !isSuccessfulSave {
            return false
        } else {
            return true
        }
    }
    
    static func loadGPS() -> [TrackPoint]? {
        
        let firstVC = FirstViewController()
        
        if var loadedGPS = NSKeyedUnarchiver.unarchiveObject(withFile: TrackPoint.ArchiveURL.absoluteString) as? [TrackPoint]
        {
            loadedGPS.append(contentsOf: firstVC.getTrackPoints())
            return loadedGPS
        }
        
        return nil
    }
    
    //MARK: Cloud Storage
    

}
