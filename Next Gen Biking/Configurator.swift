//
//  Configurator.swift
//  Next Gen Biking
//
//  Created by Bormeth, Marc on 30/12/2016.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import Foundation

class Configurator : NSObject {

    public var distanceFilter : Double
    public var zoomLevel : Double
    public var allowAutoLocationPause : Bool
    public var backendBaseURL : String
    

    
    override init() {

        var list: [String: Any] = [:]
        
        if let url = Bundle.main.url(forResource:"ConfigList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                list = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                // do something with the dictionary
            } catch {
                print(error)
            }
        }
        self.distanceFilter = (list["distance filter"] as! NSString).doubleValue
        self.allowAutoLocationPause = list["allow location pause"] as! Bool
        self.backendBaseURL = list["backend base url"] as! String
        self.zoomLevel = (list["zoom level"] as! NSString).doubleValue
        
        super.init()
        
    }
    
}
