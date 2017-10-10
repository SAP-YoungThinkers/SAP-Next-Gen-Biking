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

    // Variables
    let minSize = 31
    let maxSize = 210
    let config = Configurator()
    var tempPlaceholder : UIView?
    var locationManager = CLLocationManager()
    var currentLocation: MKUserLocation?
    var annotations : [RouteReport]? = [RouteReport]()
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    //My Routes
    var userRoutes : [String: Any]? = nil
    var userRoutesKeys = [Int]()
    var basicData : [String: Any]? = nil

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
        } else {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        myRoutesTable.dataSource = self
        myRoutesTable.delegate = self

        //Set text
        self.navigationItem.title = NSLocalizedString("marksAndRoutesTitle", comment: "")
        routeInformation.title = NSLocalizedString("routeInformation", comment: "")
        myRoutes.title = NSLocalizedString("myRoutes", comment: "")

        topBar.delegate = self
        topBar.selectedItem = routeInformation
        self.navigationItem.rightBarButtonItem?.isEnabled = true;

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
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        } else {
            // ROUTES INFORMATION
            routesInfoContent()
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }


    func myRoutesContent() {
        myRoutesList.isHidden = false
        mapView.showsUserLocation = false

        // remove annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        // route keys from keychain
        userRoutesKeys.removeAll()
        if let keys = KeychainService.loadIDs() {
            userRoutesKeys.append(contentsOf: keys)
            userRoutesKeys.sort(by: >)
        }
        
        // request and handling
        if(userRoutesKeys.count != 0) {
            
            //format for request
            let requestIDs: [String: Any] = [
                "routeIds": userRoutesKeys
            ]
            
            //Show activity indicator
            let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
            present(activityAlert, animated: false, completion: nil)
            
            if !(Reachability.isConnectedToNetwork()) {
                // no Internet connection
                
                //Dismiss activity indicator
                activityAlert.dismiss(animated: false) {
                    self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
                }
                
            } else {
                
                // good internet
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: requestIDs, options: [])
                    
                    ClientService.getBasicRoutesInfo(routeKeys: jsonData) { (routes, error) in
                        
                        if error == nil {
                            
                            activityAlert.dismiss(animated: false, completion: nil)
                            self.userRoutes = routes
                            
                            self.basicData = routes
                            
                        } else {
                            
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            
                            //An error occured in the app
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        }
                    }
                    
                    /*
                    ClientService.getRoutes(routeKeys: jsonData) { (routes, error) in
                        
                        if error == nil {
                            
                            activityAlert.dismiss(animated: false, completion: nil)
                            self.userRoutes = routes
                            
                            DispatchQueue.main.async {
                                
                                // create each route (with sorted keys)
                                for key in self.userRoutesKeys {
                                    
                                    var coorArray = [CLLocationCoordinate2D]()
                                    var isFirstPoint = true
                                    var minDate2 = Date()
                                    var maxDate = Date()
                                    var cc = CLLocationCoordinate2D()
                                    var ct = String()
                                    
                                    // for every point in that sorted array
                                    for obj in ((self.userRoutes?[String(key)] as! [[String: Any]]).sorted(by: { (a: [String : Any], b: [String : Any]) -> Bool in
                                        return self.formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: a["timestamp"] as! String) < self.formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: b["timestamp"] as! String)
                                    })) {
                                        coorArray.append(CLLocationCoordinate2D(latitude: Double(obj["latitude"] as! String)!, longitude: Double(obj["longitude"] as! String)!))
                                        if(isFirstPoint) {
                                            // create annotation at first point of each route
                                            cc = CLLocationCoordinate2D(latitude: Double(obj["latitude"] as! String)!, longitude: Double(obj["longitude"] as! String)!)
                                            minDate2 = self.formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: obj["timestamp"] as! String)
                                            ct = obj["timestamp"] as! String
                                        }
                                        isFirstPoint = false
                                        maxDate = self.formatDateAsObject(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timestamp: obj["timestamp"] as! String)
                                    }
                                    let timeDifference = Calendar.current.dateComponents([.hour, .minute], from: minDate2, to: maxDate)
                                    let pin = RouteLineAnnotation(title: "\(self.formatTwo(timeDifference.hour!)):\(self.formatTwo(timeDifference.minute!))", message: self.formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "MMMM dd", timestamp: ct), coordinate: cc)
                                    self.mapView.addAnnotation(pin)
                                    let x = MKPolyline(coordinates: UnsafeMutablePointer(mutating: coorArray), count: coorArray.count)
                                    x.title = String(key)
                                    self.mapView.add(x)
                                    
                                }
                                
                                // zoom out to everything
                                var firstRect = MKMapRectNull
                                for overlay in self.mapView.overlays {
                                    firstRect = MKMapRectUnion(firstRect, overlay.boundingMapRect)
                                }
                                self.mapView.setVisibleMapRect(firstRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
                                
                                // set first as selected
                                let currentPath = IndexPath(row: 0, section: 0)
                                self.tableView(self.myRoutesTable, didSelectRowAt: currentPath)
                                
                                
                                self.myRoutesTable.reloadData()
                            }
                            
                            
                        } else {
                            
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            
                            //An error occured in the app
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        }
                        }*/
                } catch {
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false, completion: nil)
                    
                    //An error occured in the app
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                }
                
            }
            

        } else {
            print("no own routes.")
        }

    }

    func formatTwo(_ input: Int) -> String {
        if (String(input).characters.count == 1) {
            return "0\(input)"
        }
        else {
            return "\(input)"
        }
    }



    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = primaryColor
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
        //let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
        //present(activityAlert, animated: true, completion: nil)

        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true

        
        if !(Reachability.isConnectedToNetwork()) {
            // no Internet connection
            
            self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
            
        } else {
            
            //Update annotations
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
                        
                        //Dismiss activity indicator
                        //activityAlert.dismiss(animated: false, completion: nil)
                        
                        //center map around points
                        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: self.config.zoomLevel, longitudeDelta: self.config.zoomLevel))
                        self.mapView.setRegion(region, animated: true)
                    }
                } else {
                    //Dismiss activity indicator
                    //activityAlert.dismiss(animated: false, completion: nil)
                    
                    //An error occured in the app
                    DispatchQueue.main.async {
                        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                    }
                }
            }
            
        }
        

    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //This method will be called when user changes tab.

        if(topBar.selectedItem == myRoutes) {
            // MY ROUTES
            myRoutesContent()
            self.navigationItem.rightBarButtonItem?.isEnabled = false;

        } else {
            // ROUTES INFORMATION
            routesInfoContent()
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
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
            else if (reportAnnotation.title == "Warning") {
                annotationView!.image = UIImage(named: "warning")
            }
        }
        else {
            annotationView!.image = nil
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRoutesKeys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableCell", for: indexPath) as! RouteTableCell

        print("userRoutesKeys.count \(userRoutesKeys.count)")
 
        if (userRoutesKeys.count > 0) {
            
            // for every point in that sorted array
            for route in self.basicData?["routesInfo"] as! [[String: Any]] {
                if userRoutesKeys[indexPath.row] == Int(route["id"] as! String) {
                    // correct route
                    
                    var minDate1 = ""
                    var minDate2 = ""
                    var maxDate = ""
                    
                    minDate1 = formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "MMMM dd", timestamp: route["startTime"] as! String)
                    minDate2 = formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "HH:mm a", timestamp: route["startTime"] as! String)
                    maxDate = formatDateAsString(sourceFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", targetFormat: "HH:mm a", timestamp: route["endTime"] as! String)
                    
                    // Format for left label
                    cell.rtDate.text = minDate1
                    
                    // Format for right label
                    cell.rtTime.text = "\(minDate2) - \(maxDate)"
                    
                }
            }

     

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
        
        if(userRoutes != nil) {
            
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
