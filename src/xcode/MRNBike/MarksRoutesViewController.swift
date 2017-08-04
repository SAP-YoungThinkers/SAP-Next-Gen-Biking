import UIKit
import CoreGraphics
import MapKit

class MarksRoutesViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topBar: UITabBar!
    @IBOutlet weak var routeInformation: UITabBarItem!
    @IBOutlet weak var myRoutes: UITabBarItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myRoutesList: UIView!
    @IBOutlet weak var helperSubView: UIView!
    @IBOutlet weak var myRoutesTable: UITableView!
    
    let minSize = 31
    let maxSize = 210
    
    @IBAction func minimizePressed(_ sender: UIButton) {
        
        if(myRoutesList.frame.size.height > CGFloat(minSize)) {
            // minimize
            
            let yPos = myRoutesList.frame.origin.y
            let sizes = myRoutesList.frame.size
            
            UIView.animate(withDuration: 0.2, animations: {
                sender.imageView?.layer.transform = CATransform3DRotate((sender.imageView?.layer.transform)!, CGFloat(Double.pi), 1, 0, 0)
                self.myRoutesList.frame.origin.y = yPos + (sizes.height - CGFloat(self.minSize))
                self.myRoutesList.frame.size = CGSize(width: sizes.width, height: CGFloat(self.minSize))
                self.myRoutesList.layoutIfNeeded()
            })
            
        }
        else {
            // maximize
            
            let yPos = myRoutesList.frame.origin.y
            let sizes = myRoutesList.frame.size
            
            UIView.animate(withDuration: 0.2, animations: {
                sender.imageView?.layer.transform = CATransform3DRotate((sender.imageView?.layer.transform)!, CGFloat(Double.pi), 1, 0, 0)
                self.myRoutesList.frame.origin.y = yPos - (CGFloat(self.maxSize) - sizes.height)
                self.myRoutesList.frame.size = CGSize(width: sizes.width, height: CGFloat(self.maxSize))
                self.myRoutesList.layoutIfNeeded()
            })
            
        }
        
    }
    
    
    let config = Configurator()
    
    var tempPlaceholder : UIView?
    var locationManager = CLLocationManager()
    var currentLocation: MKUserLocation?
    var annotations : [RouteReport]? = [RouteReport]()
    
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    var userRoutes : [String: Any]? = nil
    var userRoutesKeys = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRoutesTable.dataSource = self
        myRoutesTable.delegate = self
        
        //Set text
        self.title = NSLocalizedString("marksAndRoutesTitle", comment: "")
        routeInformation.title = NSLocalizedString("routeInformation", comment: "")
        myRoutes.title = NSLocalizedString("myRoutes", comment: "")
        
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
        
        /* My Routes List */
        // shadows & corner radii
        let maskPath = UIBezierPath(roundedRect: myRoutesList.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath
        maskLayer.shadowColor = UIColor.black.cgColor
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowOpacity = 0.7
        maskLayer.shadowRadius = 16.0
        maskLayer.shadowPath = maskPath
        maskLayer.shouldRasterize = true
        maskLayer.rasterizationScale = UIScreen.main.scale
        myRoutesList.layer.mask = maskLayer
        
        let helperLayer = CAShapeLayer()
        helperLayer.path = maskPath
        helperSubView.clipsToBounds = true
        helperSubView.layer.mask = helperLayer
        
        // Table insets
        myRoutesTable.separatorInset = UIEdgeInsets.zero
        myRoutesTable.layoutMargins = UIEdgeInsets.zero
        
        
        DispatchQueue.main.async {
            self.myRoutesTable.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        myRoutesList.isHidden = false
        
        mapView.showsUserLocation = false
        
        // remove annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        
        /*--------------------
         
         TODO: T E S T D A T A (turn into request)
         >>>>>>>>>>>>>>>>>>>>>*/
        
        let testdata = "{\r\n   \"100\": [\r\n      {\r\n         \"latitude\":\"49.2150001\",\r\n         \"longitude\":\"8.423952\",\r\n         \"timestamp\":\"2017-04-14T10:37:38.968Z\"\r\n      },\r\n      {\r\n         \"latitude\":\"49.294990\",\r\n         \"longitude\":\"8.443951\",\r\n         \"timestamp\":\"2017-04-14T10:37:38.978Z\"\r\n      }\r\n   ],\r\n   \"101\": [\r\n      {\r\n         \"latitude\":\"37.785831\",\r\n         \"longitude\":\"-122.409417\",\r\n         \"timestamp\":\"2017-04-25T14:07:11.194Z\"\r\n      },\r\n      {\r\n         \"latitude\":\"37.785832\",\r\n         \"longitude\":\"-122.406407\",\r\n         \"timestamp\":\"2017-04-25T14:07:13.493Z\"\r\n      },\r\n      {\r\n         \"latitude\":\"37.789835\",\r\n         \"longitude\":\"-122.410417\",\r\n         \"timestamp\":\"2017-04-25T14:07:14.203Z\"\r\n      }\r\n   ]\r\n}"
        userRoutes = testdata.toJSON() as? [String : Any]
        
        /*<<<<<<<<<<<<<<<<<<<<
         TODO: T E S T D A T A (turn into request)
         
         ---------------------*/
        
        
        // create each route (sort first)
        userRoutesKeys.removeAll()
        for (key, _) in userRoutes! {
            userRoutesKeys.append(Int(key)!)
        }
        userRoutesKeys.sort(by: >)
        
        // not asynchronous because of handling (see below)!
        self.myRoutesTable.reloadData()
        
        // create each route (with sorted keys)
        for key in userRoutesKeys {
            
            var coorArray = [CLLocationCoordinate2D]()
            var isFirstPoint = true
            var minDate2 = Date()
            var maxDate = Date()
            var cc = CLLocationCoordinate2D()
            var ct = String()
            
            // for every point in that sorted array
            for obj in ((userRoutes?[String(key)] as! [[String: Any]]).sorted(by: { (a: [String : Any], b: [String : Any]) -> Bool in
                return formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: a["timestamp"] as! String) < formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: b["timestamp"] as! String)
            })) {
                coorArray.append(CLLocationCoordinate2D(latitude: Double(obj["latitude"] as! String)!, longitude: Double(obj["longitude"] as! String)!))
                if(isFirstPoint) {
                    // create annotation at first point of each route
                    cc = CLLocationCoordinate2D(latitude: Double(obj["latitude"] as! String)!, longitude: Double(obj["longitude"] as! String)!)
                    minDate2 = formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: obj["timestamp"] as! String)
                    ct = obj["timestamp"] as! String
                }
                isFirstPoint = false
                maxDate = formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: obj["timestamp"] as! String)
            }
            let pin = RouteLineAnnotation(title: String(maxDate.timeIntervalSince(minDate2)), message: formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "MMMM dd", timestamp: ct), coordinate: cc)
            mapView.addAnnotation(pin)
            let x = MKPolyline(coordinates: UnsafeMutablePointer(mutating: coorArray), count: coorArray.count)
            x.title = String(key)
            mapView.add(x)
            
        }
        
        // zoom out to everything
        var firstRect = MKMapRectNull
        for overlay in mapView.overlays {
            firstRect = MKMapRectUnion(firstRect, overlay.boundingMapRect)
        }
        self.mapView.setVisibleMapRect(firstRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
        
        // set first as selected
        let currentPath = IndexPath(row: 0, section: 0)
        self.tableView(self.myRoutesTable, didSelectRowAt: currentPath)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 192.0/255, green: 57.0/255, blue: 43.0/255, alpha: 1.0)
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func routesInfoContent() {
        myRoutesList.isHidden = true
        
        // cleanup
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        //Show activity indicator
        let alert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
        present(alert, animated: false, completion: nil)
        
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        // ANNOTATIONS!
        ClientService.getReports { (result, error) in
            
            if error == nil {
                
                if let reports = result?["records"] as? [[String: AnyObject]] {
                    
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
                        
                        pin = RouteReport(title: type, message: description, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        self.annotations?.append(pin)
                    }
                    
                    self.mapView.addAnnotations(self.annotations!)
                    
                    //center map around points
                    let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: self.config.zoomLevel, longitudeDelta: self.config.zoomLevel))
                    self.mapView.setRegion(region, animated: true)
                    
                }
            } else {
                //alert.dismiss(animated: false, completion: nil)
                
                //Notification
            }
            alert.dismiss(animated: true, completion: nil)
        }
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
        if !(annotation is RouteReport || annotation is RouteLineAnnotation) {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        
        if annotation is RouteReport {
            let reportAnnotation = annotation as! RouteReport
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
        }
        
        return annotationView
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // only if this view was loaded and displayed!
        if (self.isViewLoaded && self.view.window != nil) {
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
        
        if let addReportViewController = segue.source as? AddReportViewController {
            
            let message: String = addReportViewController.messageTextField.text!
            
            var type : String
            
            if addReportViewController.recommendationBtn.isSelected {
                type = "Recommendation"
            } else if addReportViewController.warningBtn.isSelected {
                type = "Warning"
            } else {
                type = "Dangerous"
            }
            
            let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
            
            var annotations = addReportViewController.mapView.annotations.filter { $0 !== addReportViewController.mapView.userLocation }
            if annotations.count == 0 {
                annotations = addReportViewController.mapView.annotations.filter { $0 === addReportViewController.mapView.userLocation } }
            
            let location: MKAnnotation = annotations[0]
            let latitude: Double = location.coordinate.latitude
            let longitude: Double = location.coordinate.longitude
            
            let data : [String: Any] = ["type" : type, "description" : message, "timestamp" : timestamp, "longitude" : longitude, "latitude" : latitude]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: data)
            
            ClientService.uploadReportToHana(reportInfo: jsonData, completion: { (error) in
                if error == nil {
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("reportUploadDialogTitle", comment: ""), message: NSLocalizedString("reportUploadDialogMsgPositive", comment: "")), animated: true, completion: nil)
                }
                else
                {
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                }
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userRoutes != nil {
            return userRoutes!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableCell", for: indexPath) as! RouteTableCell
        
        
        if (userRoutes != nil) {
            
            // get element according to current row (indexpath) and provide its value
            let item = userRoutes![String(userRoutesKeys[indexPath.row])]
            
            var minDate1 = ""
            var minDate2 = ""
            var maxDate = ""
            
            var isFirstPoint = true
            // for first point in that sorted array
            for obj in ((item as! [[String: Any]]).sorted(by: { (a: [String : Any], b: [String : Any]) -> Bool in
                return formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: a["timestamp"] as! String) < formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: b["timestamp"] as! String)
            })) {
                if(isFirstPoint) {
                    minDate1 = formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "MMMM dd", timestamp: obj["timestamp"] as! String)
                    minDate2 = formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "HH:mm a", timestamp: obj["timestamp"] as! String)
                }
                isFirstPoint = false
                maxDate = formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "HH:mm a", timestamp: obj["timestamp"] as! String)
            }
            
            // Format for left label
            cell.rtDate.text = minDate1
            
            // Format for right label
            cell.rtTime.text = "\(minDate2) - \(maxDate)"
            
        }

    
        return cell
    }
    
    func formatDateAsString(sourceFormat: String, targetFormat: String, timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = sourceFormat
        let newTime : Date = formatter.date(from: timestamp)!
        
        formatter.dateFormat = targetFormat
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: newTime)
    }
    
    func formatDateAsObject(sourceFormat: String, timestamp: String) -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = sourceFormat
        let newTime : Date = formatter.date(from: timestamp)!
        
        return newTime
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // selected table row
        print("selected id: \(String(userRoutesKeys[indexPath.row])) with elements: \(((userRoutes![String(userRoutesKeys[indexPath.row])]) as! [[String: Any]]).count)")
        
        // select first point according to row
        for anno in mapView.annotations {
            
            var isFirstPoint = true
            // for every point in that sorted array
            for obj in ((userRoutes![String(userRoutesKeys[indexPath.row])] as! [[String: Any]]).sorted(by: { (a: [String : Any], b: [String : Any]) -> Bool in
                return formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: a["timestamp"] as! String) < formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: b["timestamp"] as! String)
            })) {
                if(isFirstPoint) {
                    if(anno.coordinate.latitude == Double(obj["latitude"] as! String) && anno.coordinate.longitude == Double(obj["longitude"] as! String)) {
                        mapView.selectAnnotation(anno, animated: true)
                    }
                }
                isFirstPoint = false
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

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }
}

extension Dictionary {
    subscript(i:Int) -> (key: Key, value: Value) {
        get {
            return self[self.index(self.startIndex, offsetBy: i)]
        }
    }
}
