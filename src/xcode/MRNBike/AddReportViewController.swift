

import UIKit
import MapKit
import CoreLocation

class AddReportViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var dangerLabel: UILabel!
    @IBOutlet weak var whatDidYouSeeLabel: UILabel!
    
    //Radio buttons
    @IBOutlet weak var recommendationBtn: RadioButtonClass!
    @IBOutlet weak var warningBtn: RadioButtonClass!
    @IBOutlet weak var dangerBtn: RadioButtonClass!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    let manager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.isEnabled = false
        
        //Set text
        self.title = NSLocalizedString("addRouteMarkTitle", comment: "")
        recommendationLabel.text = NSLocalizedString("recommendation", comment: "")
        warningLabel.text = NSLocalizedString("warning", comment: "")
        dangerLabel.text = NSLocalizedString("danger", comment: "")
        whatDidYouSeeLabel.text = NSLocalizedString("whatDidYouSee", comment: "")
        messageTextField.placeholder = NSLocalizedString("writeMessage", comment: "")
        
        messageTextField.textColor = UIColor.lightGray
        
        //Hide Keyboard Extension
        self.hideKeyboardWhenTappedAround()
        self.messageTextField.delegate = self
        
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
        
        //Bind textfields to regex validator
        messageTextField.addTarget(self, action:#selector(AddReportViewController.checkInput), for:UIControlEvents.editingChanged)
    }
    
    //Check if message is valid
    func checkInput() {
        
        let messageTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()@\\s]{5,60}$")
        
        //If message is valid, enable the send button
        if messageTest.evaluate(with: messageTextField.text) {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
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
    
    // Close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Actions
    
    @IBAction func onPressCancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
        /*let storyBoard: UIStoryboard = UIStoryboard(name: "Routes", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "RoutesStoryboard") as UIViewController
        self.present(newViewController, animated: true, completion: nil)
        self.close()
 */
    }
    
    @IBAction func onPressSend(_ sender: UIButton) {
        let message: String = messageTextField.text!
        
        var type : String
        
        if recommendationBtn.isSelected {
            type = "Recommendation"
        } else if warningBtn.isSelected {
            type = "Warning"
        } else {
            type = "Dangerous"
        }
        
        let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        var annotations = mapView.annotations.filter { $0 !== mapView.userLocation }
        if annotations.count == 0 {
            annotations = mapView.annotations.filter { $0 === mapView.userLocation } }
        
        let location: MKAnnotation = annotations[0]
        let latitude: Double = location.coordinate.latitude
        let longitude: Double = location.coordinate.longitude
        
        let data : [String: Any] = ["type" : type, "description" : message, "timestamp" : timestamp, "longitude" : longitude, "latitude" : latitude]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        
        //Show activity indicator
        let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
        present(activityAlert, animated: false, completion: nil)
        
        ClientService.uploadReportToHana(reportInfo: jsonData, completion: { (error) in
            if error == nil {
                //Dismiss activity indicator
                activityAlert.dismiss(animated: false, completion: nil)
                
                let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("reportUploadDialogTitle", comment: ""), message: NSLocalizedString("reportUploadDialogMsgPositive", comment: ""))
                let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                    (action) -> Void in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Routes", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "RoutesStoryboard") as UIViewController
                    self.present(newViewController, animated: true, completion: nil)
                    self.close()
                })
                alert.addAction(gotItAction)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                //Dismiss activity indicator
                activityAlert.dismiss(animated: false, completion: nil)
                
                let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: ""))
                let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                    (action) -> Void in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Routes", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "RoutesStoryboard") as UIViewController
                    self.present(newViewController, animated: true, completion: nil)
                    self.close()
                })
                alert.addAction(gotItAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBAction func refreshLocation(_ sender: UIButton) {
        manager.startUpdatingLocation()
        //manager.stopUpdatingLocation()
    }
}

