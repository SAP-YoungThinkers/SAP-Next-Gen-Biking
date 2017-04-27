//
//  RouteReport.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 27.04.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import MapKit

class RouteReport : NSObject, MKAnnotation {
    
    let reportTitle: String
    let message: String
    let coordinate: CLLocationCoordinate2D
    enum type: String {
        case Recommendation
        case Warning
        case Dangerousness
    }
    
    init(title: String, message: String, coordinate: CLLocationCoordinate2D, type : type) {
        self.reportTitle = title
        self.message = message
        self.coordinate = coordinate
        
        super.init()
    }
    
    func getType() -> String {
        return type.RawValue()
    }
    
}
