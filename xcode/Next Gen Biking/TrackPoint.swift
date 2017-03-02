//
//  gpsModel.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 23.11.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import UIKit
import MapKit


class TrackPoint: NSObject, NSCoding {
    
    //MARK: Properties
    var latitude : Double
    var longitude : Double
    var timestamp: Int64
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tp")
    // MARK: Types
    struct PropertyKey {
        static let latKey = "lat"
        static let longKey = "long"
        static let timeKey = "timestamp"
    }
    
    init(point: CLLocationCoordinate2D, timestamp: Int64) {
        self.latitude = point.latitude
        self.longitude = point.longitude
        self.timestamp = timestamp
        
        super.init()
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: PropertyKey.latKey)
        aCoder.encode(longitude, forKey: PropertyKey.longKey)
        aCoder.encode(timestamp, forKey: PropertyKey.timeKey)
        
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let time = aDecoder.decodeInt64(forKey: PropertyKey.timeKey)
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latKey)
        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.latKey)
        
        //in order to leave the constructor as simple as possible
        let point = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.init(point: point, timestamp: time)
    }
    
    
}
















