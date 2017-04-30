//
//  AddReportViewController.swift
//  MRNBike
//
//  Created by Bartosz Wilkusz on 29.04.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddReportViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    var lastUserLocation: MKUserLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let manager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    
    let button1 = RadioButtonClass(frame: CGRect(x: 20, y: 170, width: 50, height: 50))
    let button2 = RadioButtonClass(frame: CGRect(x: 20, y: 350, width: 50, height: 50))
    let button3 = RadioButtonClass(frame: CGRect(x: 20, y: 450, width: 50, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup location manager and properties
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Create buttons for custom radio buttons
        button1.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        self.view.addSubview(button1)
        button1.isSelected = true
        button1.tag = 1
        
        button2.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        self.view.addSubview(button2)
        button2.isSelected = false
        button2.tag = 2
        
        button3.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        self.view.addSubview(button3)
        button3.isSelected = false
        button3.tag = 3
        
        //Setup gesture recognizer for long press recognition
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:(#selector(longPress)))
        gestureRecognizer.minimumPressDuration = 2.0
        gestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let span = MKCoordinateSpanMake(0.00775, 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegionMake(myLocation, span)
            mapView.setRegion(region, animated: true)
        }
        self.mapView.showsUserLocation = true
        manager.stopUpdatingLocation()
    }
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let coordinate = mapView.centerCoordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func manualAction (sender: RadioButtonClass) {
        switch sender.tag
        {
        case 1:
            button1.isSelected = true
            button2.isSelected = false
            button3.isSelected = false
            break
        case 2:
            button1.isSelected = false
            button2.isSelected = true
            button3.isSelected = false
            break
        case 3:
            button1.isSelected = false
            button2.isSelected = false
            button3.isSelected = true
            break
        default: break
        }
    }
    
    //MARK: Actions
    @IBAction func refreshLocation(_ sender: UIButton) {
        //Get actual user location
        manager.startUpdatingLocation()
    }
    
    
    
}
