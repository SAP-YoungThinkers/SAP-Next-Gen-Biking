//
//  LocationManager.swift
//  Next Gen Biking
//
//  Created by Bormeth, Marc on 01/03/2017.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import Foundation
import CoreLocation


class LocatonManager: NSObject, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var config: Configurator
    
    override init() {
        config = Configurator()
        super.init()
        
        self.locationManager.delegate = self
        
        //get authorization
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        //settings
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = config.distanceFilter //treshold for movement
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = config.allowAutoLocationPause
        //pauses only, when the user does not move a significant distance over a period of time
        self.locationManager.activityType = CLActivityType.automotiveNavigation
        self.locationManager.disallowDeferredLocationUpdates()

    }
    
}
