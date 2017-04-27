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

class MarksRoutesViewController: UIViewController {
    
    @IBOutlet weak var topBar: UITabBar!
    @IBOutlet weak var routeInformation: UITabBarItem!
    @IBOutlet weak var myRoutes: UITabBarItem!
    @IBOutlet weak var mapView: MKMapView!
    
    let config = Configurator()
    
    var locationManager = LocationManager()
    var tempPlaceholder : UIView?
    
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.showsUserLocation = false
        
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
        
        // center map around position
        let centerPoint = getPosition()
        centerMap(centerPoint: centerPoint)
        
        
        // show artwork on map
        centerMap(centerPoint: CLLocationCoordinate2D(latitude: 21.283923, longitude: -157.831663))
        
        // ANNOTATION!
        let artwork = RouteReport(title: "Überschrift", message: "Nachricht blabla bla uffbasse!", coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661), type: RouteReport.type.Recommendation)
        
        mapView.addAnnotation(artwork)
    }
    
    func getPosition() -> CLLocationCoordinate2D {
        return locationManager.center
    }
    
    func centerMap(centerPoint: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: config.zoomLevel, longitudeDelta: config.zoomLevel))
        
        self.mapView.setRegion(region, animated: true)
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
