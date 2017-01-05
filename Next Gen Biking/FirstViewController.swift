//
//  FirstViewController.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 22.11.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let config = Configurator()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    
    var locationManager = CLLocationManager()
    
    var trackPointsArray = [TrackPoint]() //storing Trackpoints including timestamp
    
    var isTracking: Bool = false
    
    
    // MARK: Localized Strings
    let startString = NSLocalizedString("Start Tracking", comment: "Button tracking")
    let stopString = NSLocalizedString("Stop Tracking", comment: "Button tracking")
    let centerString = NSLocalizedString("Center map", comment: "Button center map")
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Without this function, a polyline will not be displayed on the map
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.fillColor = UIColor.red
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 2.0
        return renderer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = false
        
        
        statusBtn.setTitle(startString, for: UIControlState.normal)
        centerButton.setTitle(centerString, for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.saveCollectedDataLocally() // stores collected data in local storage
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let center = locations.last?.coordinate
        print("\(center!.latitude), \(center!.longitude)")
        let timestamp = Date().timeIntervalSince1970 * 1000 //this one is for HANA
        let currentTrackPoint = TrackPoint(point: center!, timestamp: Int64(timestamp))
        
        trackPointsArray.append(currentTrackPoint!)

        if trackPointsArray.count > 5 {
            saveCollectedDataLocally()
        }
    }
    
    // MARK: Print out error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    
    // MARK: Helper functions
    
    func stopTracking() {
        self.locationManager.stopUpdatingLocation() //this one is used in AppDelegate
    }
    
    func getPosition() -> CLLocationCoordinate2D {
        
        let location = locationManager.location
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        return center
    }
    
    func centerMap(centerPoint: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: config.zoomLevel, longitudeDelta: config.zoomLevel))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func getTrackPoints() -> [TrackPoint] { return trackPointsArray }
    
    
    /* Can be used later on to draw a line on the map */
    func polyline(points: [TrackPoint]) -> MKPolyline {
        
        var rawrCoords = [CLLocationCoordinate2D]()
        
        for current in points {
            rawrCoords.append(CLLocationCoordinate2D(latitude: current.latitude, longitude: current.longitude))
        }
    
        return MKPolyline(coordinates: &rawrCoords, count: rawrCoords.count)
        
    }
    
    func dropPin(title: String) {
        let pin = CustomPin(coordinate: mapView.userLocation.coordinate, title: title)
        mapView.addAnnotation(pin)
    }
    
    
    // MARK: Actions
    
    @IBAction func changeStatusEvent(_ sender: UIButton) {
        /* This function drops a pin on the current user location and removes it
         * if the user wants to be tracked again
         */
        
        if isTracking {
            statusBtn.setTitle(startString, for: UIControlState.normal)
            statusBtn.backgroundColor = config.greenColor
            stopTracking()
            
            isTracking = false
            dropPin(title: "🚲")
            locationManager.delegate = nil
            mapView.showsUserLocation = false
            
        }else {
            statusBtn.setTitle(stopString, for: UIControlState.normal)
            statusBtn.backgroundColor = config.redColor
            isTracking = true
            if mapView.annotations.count != 0 {
                mapView.removeAnnotation(mapView.annotations.last!)
            }
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
            let centerPoint = getPosition()
            centerMap(centerPoint: centerPoint)
        }
    }
    
    @IBAction func centerMapEvent(_ sender: UIButton) {
        if trackPointsArray.count > 0 {
            centerMap(centerPoint: getPosition())
        }
    }
    
    // MARK: NSCoding
    func saveCollectedDataLocally(){
        
        if StorageHelper.storeLocally(trackPointsArray: trackPointsArray) {
            trackPointsArray.removeAll() // in order to dispose used memory
        }
        

    }
    
}

