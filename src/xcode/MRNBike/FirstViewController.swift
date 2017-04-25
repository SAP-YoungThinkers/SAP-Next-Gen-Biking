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

class FirstViewController: UIViewController {
    
    let config = Configurator()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    
    var locationManager = LocationManager()
    
    var trackPointsArray = [TrackPoint]() //storing Trackpoints including timestamp
    
    var isTracking: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = false
        
        statusBtn.setTitle(NSLocalizedString("Start_Tracking", comment: "Start updating location"), for: UIControlState.normal)
        centerButton.setTitle(NSLocalizedString("center", comment: "Generic String for center button"), for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.saveCollectedDataLocally() // stores collected data in local storage
    }
    
    // MARK: Helper functions
    
    func getPosition() -> CLLocationCoordinate2D {
        return locationManager.center
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
            statusBtn.setTitle(NSLocalizedString("Start_Tracking", comment: "Start updating location"), for: UIControlState.normal)
            statusBtn.backgroundColor = config.greenColor
            self.locationManager.stopTracking()
            
            isTracking = false
            dropPin(title: "🚲")
            locationManager.delegate = nil
            mapView.showsUserLocation = false
            
            saveCollectedDataLocally()
        } else {
            statusBtn.setTitle(NSLocalizedString("Stop_Tracking", comment: "Stop updating location"), for: UIControlState.normal)
            statusBtn.backgroundColor = config.redColor
            isTracking = true
            if mapView.annotations.last != nil {
                mapView.removeAnnotation(mapView.annotations.last!)
            }
            locationManager.delegate = self
            locationManager.startTracking()
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

extension FirstViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Without this function, a polyline will not be displayed on the map
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.fillColor = UIColor.red
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 2.0
        return renderer
    }
}

extension FirstViewController: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D) {
        let timestamp = Date().timeIntervalSince1970 * 1000 //this one is for HANA
        let currentTrackPoint = TrackPoint(point: location, timestamp: Int64(timestamp))
        
        trackPointsArray.append(currentTrackPoint)
    }
}
