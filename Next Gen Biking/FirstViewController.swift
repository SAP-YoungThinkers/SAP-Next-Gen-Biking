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
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var centerButton: MKMapView!
    
    //var trackingTimer = Timer()
    
    var locationManager = CLLocationManager()
    
    var trackPointsArray = [TrackPoint]()
//  var coords = [CLLocationCoordinate2D]() //needed for drawing the cyclist's path
    
    var isTracking: Bool = true //used for the timer-function
    
    
    // Used for zooming into the "right" height
    var latDelta = 0.02
    var longDelta = 0.02
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.fillColor = UIColor.red
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 2.0
        return renderer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let directories: [String]?
//        directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//        print(directories!.first!)
        
//        trackingTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //treshold for movement
        self.locationManager.distanceFilter = 3.0
        centerButton.layer.cornerRadius = 42.0
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        let center = getPosition()
        centerMap(centerPoint: center)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.saveCollectedDataLocally() // stores collected data in local storage
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let center = locations.last?.coordinate
        print("\(center!.latitude), \(center!.longitude)")
        let timestamp = Date().timeIntervalSince1970 * 1000
        let currentTrackPoint = TrackPoint(point: center!, timestamp: Int64(timestamp))
        
        trackPointsArray.append(currentTrackPoint!)

        
        if trackPointsArray.count > 3 {
            //mapView.add(polyline())
            saveCollectedDataLocally()
        }
//        if trackPointsArray.count > 4{
//            loadGPS()
//        }
        
    }
    
    func dropPin() {
        let pin = CustomPin(coordinate: mapView.userLocation.coordinate, title: "🚲")
        mapView.addAnnotation(pin)
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
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func getTrackPoints() -> [TrackPoint] { return trackPointsArray }

//    func polyline() -> MKPolyline {
        //var testcoords = [CLLocationCoordinate2D]()
        //let lastPoint = CLLocationCoordinate2D(latitude: trackPointsArray[trackPointsArray.count-1].latitude, longitude: trackPointsArray[trackPointsArray.count-1].longitude)
        
        
       // let preLastPoint = CLLocationCoordinate2D(latitude: trackPointsArray[trackPointsArray.count-2].latitude, longitude: trackPointsArray[trackPointsArray.count-2].longitude)
        
//        let preLastPoint = CLLocationCoordinate2D(latitude: lastPoint.latitude, longitude: lastPoint.longitude + 0.004)
//        
        //testcoords.append(lastPoint)
        //testcoords.append(preLastPoint)
        
//        return MKPolyline(coordinates: &coords, count: coords.count)
        //return MKPolyline(coordinates: &testcoords, count: coords.count)
        
    //}
    
    
    // MARK: Actions

    @IBOutlet weak var statusBtn: UIButton!
    @IBAction func changeStatusEvent(_ sender: UIButton) {
        if isTracking {
            statusBtn.setTitle("Start Tracking", for: UIControlState.normal)
            statusBtn.backgroundColor = UIColor(red:0.14, green:0.45, blue:0.19, alpha:1.0)
            stopTracking()
            
            isTracking = false
            dropPin()
            locationManager.delegate = nil
            mapView.showsUserLocation = false
            
        }else {
            statusBtn.setTitle("Stop Tracking", for: UIControlState.normal)
            statusBtn.backgroundColor = UIColor(red:1.0, green:0.4, blue:0.4, alpha:1.0)
            isTracking = true
            mapView.removeAnnotation(mapView.annotations.last!)
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    @IBAction func centerMapEvent(_ sender: UIButton) {
        if trackPointsArray.count > 0 {
            centerMap(centerPoint: getPosition())
        }
    }
    
    // MARK: NSCoding
    func saveCollectedDataLocally(){
        
        if UploadHelper.storeLocally(trackPointsArray: trackPointsArray) {
            print("Successful save")
            trackPointsArray.removeAll() // in order to dispose used memory
        }
        

    }
    
}

