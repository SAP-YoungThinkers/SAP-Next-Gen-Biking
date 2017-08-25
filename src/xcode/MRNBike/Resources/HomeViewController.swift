

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
    @IBOutlet weak var DayOne_Text: UILabel!
    @IBOutlet weak var DayTwo_Text: UILabel!
    @IBOutlet weak var DayThree_Text: UILabel!
    @IBOutlet weak var DayFour_Text: UILabel!
    @IBOutlet weak var DayFive_Text: UILabel!
    @IBOutlet weak var DaySix_Text: UILabel!
    @IBOutlet weak var DayOne_Pic: UIImageView!
    @IBOutlet weak var DayTwo_Pic: UIImageView!
    @IBOutlet weak var DayThree_Pic: UIImageView!
    @IBOutlet weak var DayFour_Pic: UIImageView!
    @IBOutlet weak var DayFive_Pic: UIImageView!
    @IBOutlet weak var DaySix_Pic: UIImageView!
    @IBOutlet weak var DayOne_Weather: UILabel!
    @IBOutlet weak var DayTwo_Weather: UILabel!
    @IBOutlet weak var DayThree_Weather: UILabel!
    @IBOutlet weak var DayFour_Weather: UILabel!
    @IBOutlet weak var DayFive_Weather: UILabel!
    @IBOutlet weak var DaySix_Weather: UILabel!
    @IBOutlet weak var CurrentDate_Pic: UIImageView!

    
    
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
        setupLocation()
        setupDate()
        setupNextDates()
    }
    
    func setupNextDates() {
        guard let date0 = addDayToDate(today: Date()) else {
            return
        }
        let dayName = getDayName(fromDate: date0)
        DayOne_Text.text = dayName
        
        
        guard let date1 = addDayToDate(today: date0) else {
            return
        }
        let dayName0 = getDayName(fromDate: date1)
        DayTwo_Text.text = dayName0
        
        guard let date2 = addDayToDate(today: date1) else {
            return
        }
        let dayName1 = getDayName(fromDate: date2)
        DayThree_Text.text = dayName1
        
        guard let date3 = addDayToDate(today: date2) else {
            return
        }
        let dayName2 = getDayName(fromDate: date3)
        DayFour_Text.text = dayName2

        guard let date4 = addDayToDate(today: date3) else {
            return
        }
        let dayName3 = getDayName(fromDate: date4)
        DayFive_Text.text = dayName3

        
        guard let date5 = addDayToDate(today: date4) else {
            return
        }
        let dayName4 = getDayName(fromDate: date5)
        DaySix_Text.text = dayName4
    }
    
    func setupLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func addDayToDate(today: Date) -> Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: today)
    }
    
    func getDayName(fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
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
            forecastWeather(lat: lat, long: long)
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

                                
                            }
                        }
                        if (key == "cod") {
                           
                            switch value as! Int {
                                
                            case 200...299, 300...399,500...599, 906: //Rain
                                self.CurrentDate_Pic.image = UIImage(named:"big_rainy-1x")!
                                
                            case 700...799, 802,803,804,900,901,902,903,905,951...962: //Clouds
                                self.CurrentDate_Pic.image = UIImage(named:"big_cloudy-1x")!
                                
                            case  800,904: //Sunny
                                self.CurrentDate_Pic.image = UIImage(named:"big_sunny-1x")!
                                
                            case 801: //Overcast
                                
                                self.CurrentDate_Pic.image = UIImage(named:"big_cloudy-sunny-1x")!
                                
                            default:
                                self.CurrentDate_Pic.image = UIImage(named:"big_sunny-1x")!

                            }
                            

                        }
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
    

    func forecastWeather(lat: String, long: String) {
        print("weather: ---------")
        let appKey = "f65a7da957a554bd4dd2632dbe32d69b"
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
                            let list = value as! [[String: Any]]
                            
                            for index in 0..<list.count {
                                let subkey = list[index]
                                let subValue = "\(((subkey["temp"] as! [String: Any])["day"]!))"
                                let doubleValue = Double(subValue)
                                let textValue = String(self.convertKtoC(doubleValue!))
                                if index == 0 {
                                    self.DayOne_Weather.text = textValue
                                } else if index == 1 {
                                    self.DayTwo_Weather.text = textValue
                                } else if index == 2 {
                                    self.DayThree_Weather.text = textValue
                                } else if index == 3 {
                                    self.DayFour_Weather.text = textValue
                                } else if index == 4 {
                                    self.DayFive_Weather.text = textValue
                                } else if index == 5 {
                                    self.DaySix_Weather.text = textValue
                                }
                            }
                            
                            for index in 0..<list.count {
                                let subkey = list[index]
                                let weatherArray = subkey["weather"] as! [Any]
                                let dictionaryData = weatherArray[0] as! [String : Any]
                                let valueFinally = dictionaryData["main"]!

                                if index == 0 {
                                    self.DayOne_Pic.image = self.getImage(forName: valueFinally as! String)
                                } else if index == 1 {
                                    self.DayTwo_Pic.image = self.getImage(forName: valueFinally as! String)
                                } else if index == 2 {
                                    self.DayThree_Pic.image = self.getImage(forName: valueFinally as! String)
                                } else if index == 3 {
                                    self.DayFour_Pic.image = self.getImage(forName: valueFinally as! String)
                                } else if index == 4 {
                                    self.DayFive_Pic.image = self.getImage(forName: valueFinally as! String)
                                } else if index == 5 {
                                    self.DaySix_Pic.image = self.getImage(forName: valueFinally as! String)
                                }
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
    
    
    
    func getImage(forName imageName: String) -> UIImage {
        
        if imageName == "Clouds" || imageName == "Mist" || imageName == "Fog" {
            
            return UIImage(named: "cloudy-1x")!
            
        } else if imageName == "Clear" {
            
            return UIImage(named: "sunny-1x")!
            
        }
        else if imageName == "Rain" || imageName == "Thunderstorm" || imageName == "Drizzle" {
            
            return UIImage(named: "rainy")!
            
        }
      return UIImage(named: "cloudy-sunny")!
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
