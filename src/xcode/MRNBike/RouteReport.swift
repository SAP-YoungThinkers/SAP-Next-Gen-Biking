//
//  RouteReport.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 27.04.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import MapKit

class RouteReport : NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var pinType: String
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    enum Types: String {
        case Recommendation
        case Warning
        case Dangerousness
    }
    
    init(title: String, message: String, coordinate: CLLocationCoordinate2D, type : Types) {
        self.subtitle = message
        self.coordinate = coordinate
        
        switch type {
        case .Recommendation: pinType = Types.Recommendation.rawValue
        case .Warning: pinType = Types.Warning.rawValue
        case .Dangerousness : pinType = Types.Recommendation.rawValue
        }
        
        switch type {
        case .Dangerousness: self.title = "Danger"
        case .Recommendation: self.title = "Recommendation"
        case .Warning: self.title = "Warning"
        }
        
        super.init()
    }
    
}
