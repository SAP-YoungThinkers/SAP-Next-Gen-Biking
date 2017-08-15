

import UIKit
import CoreLocation


class HomeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var wheelRotationValue: UILabel!
    @IBOutlet weak var wheelRotationLabel: UILabel!
    @IBOutlet weak var burgerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var treesSavedLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var burgersLabel: UILabel!
    @IBOutlet weak var co2Label: UILabel!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var labelCurrentDate: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()

    /* Weather */
    @IBOutlet weak var actualWeather: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        wheelRotationLabel.text = NSLocalizedString("wheelRotation", comment: "")
        burgersLabel.text = NSLocalizedString("burgersBurned", comment: "")
        distanceText.text = NSLocalizedString("distanceKM", comment: "")
        co2Label.text = NSLocalizedString("co2Saved", comment: "")
        myProfileButton.setTitle(NSLocalizedString("myProfile", comment: ""), for: .normal)
        startTrackingButton.setTitle(NSLocalizedString("startTracking", comment: ""), for: .normal)
        
        /* Weather */
        // get user location
        
        // add parameters for location and use user location
        // currentWeather(a: 0.0, b: 0.0)
        forecastWeather()
        setupLocation()
        setupDate()
    }
    
    func setupLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupDate() {
        let formatter = DateFormatter()
        // Saturday. 6 May
        formatter.dateFormat = "EEEE.dd MMM"
        let currentDate = formatter.string(from: Date())
        labelCurrentDate.text = currentDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.actualWeather.text = "-"
        if let lastLocation: CLLocation = locations.last {
            let lat = String(format: "%.6f", lastLocation.coordinate.latitude)
            let long = String(format: "%.6f", lastLocation.coordinate.longitude)
            currentWeather(lat: lat, long: long)
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
        }
    }
    
    func currentWeather(lat: String, long: String) {
        print("weather: ---------")
        let appKey = "f65a7da957a554bd4dd2632dbe32d69b"
        let requestURL: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=\(appKey)")!
        print(requestURL)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("JSON Downloaded Sucessfully.")
                
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
                    print(jsonData)
                    
                    for (key, value) in jsonData as! [String: Any] {
                        if(key == "main") {
                            for (subkey, subvalue) in value as! [String: Any] {
                                if (subkey == "temp") {
                                    self.actualWeather.text = String(self.convertKtoC(subvalue as! Double))
                                    break
                                }
                                // ...
                            }
                        }
                        // ...
                    }
                    
                    
                }
                    
                catch {
                    print("Error with Json: \(error)")
                }
                
            }
            else {
                print("error: \(statusCode)")
            }
            
            
        }
        
        task.resume()
    }
    
    func forecastWeather() {
        print("weather: ---------")
        let appKey = "f65a7da957a554bd4dd2632dbe32d69b"
        var lat = "12.222"
        var long = "12.22"
        let requestURL: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(long)&appid=\(appKey)&cnt=6")!
        print(requestURL)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("JSON Downloaded Sucessfully.")
                
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
                    print(jsonData)
                    
                    for (key, value) in jsonData as! [String: Any] {
                        if(key == "list") {
                            for subkey in value as! [[String: Any]] {
                                print((subkey["temp"] as! [String: Any])["day"]!)
                                //print((subkey["weather"] as! [String: [String: Any]]).first?.value["main"]!)
                                // ...
                            }
                        }
                        // ...
                    }
                    
                    
                }
                    
                catch {
                    print("Error with Json: \(error)")
                }
                
            }
            else {
                print("error: \(statusCode)")
            }
            
            
        }
        
        task.resume()
    }
    
    func convertKtoC(_ f: Double) -> Int {
        return Int(f-273.15)
    }
    
    
    //Method to be called each time the screen appears to update the UI.
    private func updateUI() {
        // Setting The Username to the Label in Home Screen.
        let user = User.getUser()
        
        if let firstName = user.firstName {
            userNameLabel.text = firstName
        }
        if let wheelRotation = user.wheelRotation {
            wheelRotationValue.text = String(wheelRotation)
        }
        if let burgersBurned = user.burgersBurned {
            burgerLabel.text = String(burgersBurned)
        }
        if let distanceMade = user.distanceMade {
            distanceLabel.text = String(distanceMade)
        }
        if let co2Saved = user.co2Saved {
            treesSavedLabel.text = String(co2Saved)
        }
        //Updating the Picture in Homescreen.
        if let image = user.profilePicture {
            userImage.image = UIImage(data: image)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
