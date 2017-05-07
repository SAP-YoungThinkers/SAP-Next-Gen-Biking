//
//  ThisTracking.swift
//  MRNBike
//
//  Created by seirra on 2017/5/6.
//  Copyright © 2017年 Marc Bormeth. All rights reserved.
//

import UIKit
import os.log

//This file is for recording the tracking data

class ThisTracking: NSObject, NSCoding{
    
    
    var wheels: Int
    var location: String
    var duration: Int
    var burgers: Float
    var distance: Float
    var trees: Float
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("thistracking")
    
    //MARK: Types
    
    struct PropertyKey {
        static let wheels = "wheels"
        static let location = "location"
        static let duration = "duration"
        static let burgers = "burgers"
        static let distance = "distance"
        static let trees = "trees"
    }
    
    
    init(wheels:Int, location:String, duration:Int,burgers:Float,distance:Float,trees:Float){
        self.wheels=wheels
        self.location=location
        self.duration=duration
        self.burgers=burgers
        self.distance=distance
        self.trees=trees
    }
    
    //Mark: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(wheels, forKey: PropertyKey.wheels)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(duration, forKey: PropertyKey.duration)
        aCoder.encode(burgers, forKey: PropertyKey.burgers)
        aCoder.encode(distance, forKey: PropertyKey.distance)
        aCoder.encode(trees, forKey: PropertyKey.trees)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The wheels is required
        guard let duration = aDecoder.decodeObject(forKey: PropertyKey.duration) as? Int else {
            os_log("Unable to decode the duration", log: OSLog.default, type: .debug)
            return nil
        }
        
        // the others are an optional property of Meal, just use conditional cast.
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? String
        let wheels = aDecoder.decodeInteger(forKey: PropertyKey.wheels) as? Int
        let burgers = aDecoder.decodeFloat(forKey: PropertyKey.burgers) as? Float
        let distance = aDecoder.decodeFloat(forKey: PropertyKey.distance) as? Float
        let trees = aDecoder.decodeFloat(forKey: PropertyKey.trees) as? Float
        
        // Must call designated initializer.
        self.init(wheels: wheels!, location: location!, duration: duration, burgers: burgers!, distance:distance!, trees:trees!)
    }
    
    
    
}


