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

class AddReportViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UITextView!
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
        
        //Delegate textView Control for dismiss keyboard on pressing "return" key
        textView.delegate = self
        
        //Set a placeholder for textView because it doesn't have inherently a placeholder    
        textView.text = "Message..."
        textView.textColor = UIColor.lightGray
        
        //Notification for keyboard will show/will hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Hide Keyboard when touching anywhere except the keyboard
        self.hideKeyboardWhenTappedAround()
        
        //Setup location manager and properties
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup gesture recognizer for long press recognition
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:(#selector(longPress)))
        gestureRecognizer.minimumPressDuration = 1.5
        gestureRecognizer.delegate = self as UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(gestureRecognizer)
        
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
        
        //Border from the bottom background view
        self.messageView.layer.borderColor = UIColor.gray.cgColor
        self.messageView.layer.borderWidth = 1
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
    
    //Set pin for report
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let saveAnnotation: MKPointAnnotation = MKPointAnnotation()
        
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        let coordinate = mapView.centerCoordinate
        saveAnnotation.coordinate = coordinate
        print(coordinate)
        
        mapView.addAnnotation(saveAnnotation)
    }
    
    //Two functions for moving the screens content up so the keyboard doesn't mask the content and down
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    //Delete the programatically set placeholder in the textView when editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    //If the user left textView empty, show the placeholder again
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if(text == "\n") {
            view.endEditing(true)
            return false
        }
        return true
    }
    
    //MARK: Actions
  
    @IBAction func refreshLocation(_ sender: UIButton) {
        manager.startUpdatingLocation()
        //manager.stopUpdatingLocation()
    }
}

