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

class AddReportViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageBox: UITextField!
    @IBOutlet weak var messageView: UIView!
    
    //Radio buttons
    
    @IBOutlet weak var recommendationBtn: RadioButtonClass!
    
    @IBOutlet weak var warningBtn: RadioButtonClass!
    
    @IBOutlet weak var dangerBtn: RadioButtonClass!
    
    let manager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000

    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageBox.delegate = self
        
        //Setup location manager and properties
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Settings from the radio buttons
        recommendationBtn.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        self.view.addSubview(recommendationBtn)
        recommendationBtn.isSelected = true
        recommendationBtn.tag = 1
        
        warningBtn.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        self.view.addSubview(warningBtn)
        warningBtn.isSelected = false
        warningBtn.tag = 2
        
        dangerBtn.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        self.view.addSubview(dangerBtn)
        dangerBtn.isSelected = false
        dangerBtn.tag = 3
        
        //Setup gesture recognizer for long press recognition
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:(#selector(longPress)))
        gestureRecognizer.minimumPressDuration = 2.0
        gestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //Border from the bottom background view
        self.messageView.layer.borderColor = UIColor.gray.cgColor
        self.messageView.layer.borderWidth = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let message: String = messageBox.text!
        var type : String
        
        if recommendationBtn.isSelected {
            type = "Recommendation"
        } else if warningBtn.isSelected {
            type = "Warning"
        } else {
            type = "Dangerousness"
        }
        
        var timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
        timestamp += timestamp + 7200
        
        let location: MKAnnotation = mapView.annotations.last!
        let longitude: Double = location.coordinate.latitude
        let latitude: Double = location.coordinate.longitude
        
        let data : [String: Any] = ["type" : type, "description" : message, "timestamp" : timestamp, "long" : longitude, "lat" : latitude]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: data)

        StorageHelper.uploadReportToHana(scriptName: "report/createReport.xsjs", paramDict: nil, data: jsonData)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let span = MKCoordinateSpanMake(0.00775, 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegionMake(myLocation, span)
            mapView.setRegion(region, animated: true)
        }
        //self.mapView.showsUserLocation = true
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
            recommendationBtn.isSelected = true
            warningBtn.isSelected = false
            dangerBtn.isSelected = false
            break
        case 2:
            recommendationBtn.isSelected = false
            warningBtn.isSelected = true
            dangerBtn.isSelected = false
            break
        case 3:
            recommendationBtn.isSelected = false
            warningBtn.isSelected = false
            dangerBtn.isSelected = true
            break
        default: break
        }
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ messageBox: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //MARK: Actions
    
    //Focus back on users location
    @IBAction func refreshLocation(_ sender: UIButton) {
        //Get actual user location
        manager.startUpdatingLocation()
    }
    
    
    
}
