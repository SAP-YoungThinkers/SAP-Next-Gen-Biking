//
//  MarksRoutesViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 26.04.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//
import UIKit
import CoreGraphics
import MapKit

class MarksRoutesViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var topBar: UITabBar!
    @IBOutlet weak var routeInformation: UITabBarItem!
    @IBOutlet weak var myRoutes: UITabBarItem!
    @IBOutlet weak var mapView: MKMapView!
    
    let config = Configurator()
    
    var tempPlaceholder : UIView?
    var locationManager = CLLocationManager()
    var currentLocation: MKUserLocation?
    var annotations : [RouteReport]? = [RouteReport]()
    
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        topBar.delegate = self
        
        topBar.selectedItem = routeInformation
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        // Map preperations
        mapView.delegate = self
        mapView.mapType = .standard
        
        // Remove Grey Lines by initialising empty Image
        topBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // Set Font, Size for Items
        for item in topBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
            item.titlePositionAdjustment = UIOffset.init(horizontal: 0, vertical: -17)
        }
        
        // fix size errors
        topBar.bounds.size.width = UIScreen.main.bounds.width
        topBar.itemWidth = CGFloat(topBar.bounds.size.width/CGFloat(topBar.items!.count))
        topBar.updateConstraints()
        
        // display line on selected
        topBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: topBar.frame.width/CGFloat(topBar.items!.count), height: topBar.frame.height), lineWidth: 3.0)
        
        // add seperator
        tempPlaceholder = setupTabBarSeparators()
        
        
        // WHICH TAB SELECTED?
        
        if(topBar.selectedItem == myRoutes) {
            
            // MY ROUTES
            myRoutesContent()
            
            
        } else {
            
            // ROUTES INFORMATION
            routesInfoContent()

        }
    }
    
    func myRoutesContent() {
        
        mapView.showsUserLocation = false
        
        // remove annotations
        mapView.removeAnnotations(annotations!)
        
        
        //TODO: Add my Routes
        
        
        //TODO: focus map around routes
    }
    
   
    func routesInfoContent() {
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        // ANNOTATIONS!
        
        //Get the reports from Backend
        var result = StorageHelper.prepareRequest(scriptName: "report/queryReport.xsjs")
        
        if let reports = result["records"] as? [[String: AnyObject]] {
            
            var description : String
            var type : String
            var lat : String
            var long : String
            var latitude : Double
            var longitude : Double
            var pin : RouteReport
            
            for report in reports {
                description = (report["description"] as? String)!
                type = (report["type"] as? String)!
                lat = (report["latitude"] as? String)!
                long = (report["longitude"] as? String)!
                
                latitude = Double(lat)!
                longitude = Double(long)!
                
                print(latitude)
                print(longitude)
                
                pin = RouteReport(title: type, message: description, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                
                annotations?.append(pin)
            }
        }
        
        mapView.addAnnotations(annotations!)
        
        // center map around points
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: config.zoomLevel, longitudeDelta: config.zoomLevel))
        mapView.setRegion(region, animated: true)
        
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //This method will be called when user changes tab.
        
        if(topBar.selectedItem == myRoutes) {
            // MY ROUTES
            myRoutesContent()
            
            
        } else {
            // ROUTES INFORMATION
            routesInfoContent()
            
        }
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: config.zoomLevel, longitudeDelta: config.zoomLevel))
        mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        if !(annotation is RouteReport) {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let reportAnnotation = annotation as! RouteReport
        
        // Accessory
        
        if (reportAnnotation.title == "Dangerous") {
            annotationView!.image = UIImage(named: "dangerous")
        }
        else if (reportAnnotation.title == "Recommendation") {
            annotationView!.image = UIImage(named: "recommendation")
        }
        else {
            // Warning
            annotationView!.image = UIImage(named: "warning")
        }
        
        return annotationView
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            
            switch orient {
            case .portrait:
                print("Portrait")
            default:
                print("Anything But Portrait")
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            // on device orientation change
            
            // update lines
            self.updateTapBar()
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func updateTapBar() {
        
        // remove seperators and images
        self.tempPlaceholder?.removeFromSuperview()
        topBar.selectionIndicatorImage = UIImage()
        
        // add again
        self.tempPlaceholder? = setupTabBarSeparators()
        topBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: topBar.frame.width/CGFloat(topBar.items!.count), height: topBar.frame.height), lineWidth: 3.0)
        
    }

    
    func setupTabBarSeparators() -> UIView {
        let itemWidth = floor(self.topBar.frame.width / CGFloat(self.topBar.items!.count))
        
        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5
        
        
            // make a new separator at the end of each tab bar item
            let separator = UIView(frame: CGRect(x: itemWidth + 0.5 - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.topBar.frame.height))
            
            // set the color to light gray (default line color for tab bar)
            separator.backgroundColor = UIColor(red: (170/255.0), green: (170/255.0), blue: (170/255.0), alpha: 1.0)
            
        self.topBar.insertSubview(separator, at: 1)
        
        
        return separator
    }
    
    
    
    //MARK: Actions
    
    @IBAction func cancelToMarksRoutesViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveReport(segue:UIStoryboardSegue) {
        
        var status: String = ""
        var alertTitle: String = ""
        var alertMessage: String = ""
        
        if let addReportViewController = segue.source as? AddReportViewController {
            
            var message: String = String(addReportViewController.textView.text)
            
            //Check if the user hasn't add any message.
            if message == "Message..." {
                    message = "No information"
            }
            
            var type : String
            
            if addReportViewController.recommendationBtn.isSelected {
                type = "Recommendation"
            } else if addReportViewController.warningBtn.isSelected {
                type = "Warning"
            } else {
                type = "Dangerous"
            }
            
            let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
            
            let location: MKAnnotation = addReportViewController.mapView.annotations.last!
            let latitude: Double = location.coordinate.latitude
            let longitude: Double = location.coordinate.longitude
            
            let data : [String: Any] = ["type" : type, "description" : message, "timestamp" : timestamp, "longitude" : longitude, "latitude" : latitude]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: data)
            
            status = StorageHelper.uploadReportToHana(scriptName: "report/createReport.xsjs", paramDict: nil, data: jsonData)
            
            if status == "1" {
                alertTitle = "Upload successful"
                alertMessage = "Report uploaded."
            } else if status == "2" {
                alertTitle = "Error"
                alertMessage = "Something went wrong."
            } else {
                alertTitle = "Error"
                alertMessage = status
            }
            
        }
    }
    
}

extension UIImage {
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint(x: 0,y :size.height - lineWidth), size: CGSize(width: size.width, height: lineWidth)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
