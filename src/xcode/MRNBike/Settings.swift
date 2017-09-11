import UIKit
        
        class SettingsViewController: UIViewController {
            
            @IBOutlet weak var busButton: UIButton!
            @IBOutlet weak var trainButton: UIButton!
            @IBOutlet weak var CarButton: UIButton!
            @IBOutlet weak var LogoutButton: UIButton!
            @IBOutlet weak var infoLabel: UILabel!
            @IBOutlet weak var settingsLabel: UILabel!
            let BusColorimage = UIImage(named: "Bus") as UIImage?
            let BusBlackimage = UIImage(named: "BusBlack") as UIImage?
            let CarColorimage = UIImage(named: "Car") as UIImage?
            let CarBlackimage = UIImage(named: "CarBlack") as UIImage?
            let TrainColorimage = UIImage(named: "Train") as UIImage?
            let TrainBlackimage = UIImage(named: "TrainBlack") as UIImage?
            
            var tempstate: UIControlState = []
            let selcolor = UIColor(hexString: "27AE60")
            
            override func viewDidLoad() {
                super.viewDidLoad()
                
                LogoutButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
                infoLabel.text = NSLocalizedString("chooseCo2Type", comment: "")
                settingsLabel.text = NSLocalizedString("settingsTitle", comment: "")
                
                // Identify setted object
                let user = User.getUser()
                
                if let co2Choice = user.co2Type {
                    switch co2Choice {
                    case User.co2ComparedObject.car:
                        CarButton.setBackgroundImage(CarColorimage, for: tempstate)
                        CarButton.borderWidth = 2
                        CarButton.borderColor = selcolor
                    //user.co2Emissions
                    case User.co2ComparedObject.train:
                        trainButton.setBackgroundImage(TrainColorimage, for: tempstate)
                        trainButton.borderWidth = 2
                        trainButton.borderColor = selcolor
                    case User.co2ComparedObject.bus:
                        busButton.setBackgroundImage (BusColorimage, for: tempstate)
                        busButton.borderWidth = 2
                        busButton.borderColor = selcolor
                    default:
                        CarButton.setBackgroundImage(CarColorimage, for: tempstate)
                        CarButton.borderWidth = 2
                        CarButton.borderColor = selcolor
                    }
                }
                else {
                    CarButton.setBackgroundImage(CarColorimage, for: tempstate)
                    CarButton.borderWidth = 2
                    CarButton.borderColor = selcolor
                }
                
            }
            
            @IBAction func carObject_press(_ sender: Any) {
                CarButton.setBackgroundImage(CarColorimage, for: tempstate)
                trainButton.setBackgroundImage(TrainBlackimage, for: tempstate)
                busButton.setBackgroundImage(BusBlackimage, for: tempstate)
                CarButton.borderWidth = 2
                CarButton.borderColor = selcolor
                trainButton.borderWidth = 0
                busButton.borderWidth = 0
                
                CO2HANASend(type: "car")
                
            }
            
            @IBAction func trainObject_press(_ sender: Any) {
                CarButton.setBackgroundImage(CarBlackimage, for: tempstate)
                trainButton.setBackgroundImage(TrainColorimage, for: tempstate)
                busButton.setBackgroundImage(BusBlackimage, for: tempstate)
                trainButton.borderWidth = 2
                trainButton.borderColor = selcolor
                CarButton.borderWidth = 0
                busButton.borderWidth = 0
                
                CO2HANASend(type: "train")
            }
            
            @IBAction func busObject_press(_ sender: Any) {
                CarButton.setBackgroundImage(CarBlackimage, for: tempstate)
                trainButton.setBackgroundImage(TrainBlackimage, for: tempstate)
                busButton.setBackgroundImage (BusColorimage, for: tempstate)
                busButton.borderWidth = 2
                busButton.borderColor = selcolor
                trainButton.borderWidth = 0
                CarButton.borderWidth = 0
                
                CO2HANASend(type: "bus")
            }
            
            @IBAction func Logout_Press(_ sender: Any) {
                //Remove user singleton
                User.deleteSingleton()
                
                KeychainService.saveRemember(token: "no" as NSString)
                
                let storyboard = UIStoryboard(name: "StartPage", bundle: nil)
                let controller = storyboard.instantiateInitialViewController()!
                self.present(controller, animated: true, completion: nil)
            }
            
            // TODO: ADD code for sending co2Choice to SAP HANA
            func CO2HANASend(type: String) {
                
                let user = User.getUser()
                user.co2Type = User.co2ComparedObject.car
                
                //Upload updated user to Hana
                let uploadData : [String: Any] = ["email" : KeychainService.loadEmail()! as String, "password" : KeychainService.loadPassword()! as String, "firstname" : user.firstName!, "lastname" : user.surname! , "allowShare" : user.shareInfo!, "wheelsize" : user.userWheelSize!, "weight" : user.userWeight!, "burgersburned" : user.burgersBurned!, "wheelrotation" : user.wheelRotation!, "distancemade" : user.distanceMade!, "co2Type" : type]
                
                let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
                
                //Try update user profile
                ClientService.postUser(scriptName: "updateUser.xsjs", userData: jsonData) { (httpCode, error) in
                    if error == nil {
                        
                        switch httpCode! {
                        case 200: //User successfully updated
                            switch type {
                            case "car":
                                user.co2Type = User.co2ComparedObject.car
                            case "bus":
                                user.co2Type = User.co2ComparedObject.bus
                            case "train":
                                user.co2Type = User.co2ComparedObject.train
                            default:
                                user.co2Type = User.co2ComparedObject.car
                            }
                            break
                        default: //For http error code: 500
                            //An error occured in the app
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        //An error occured in the app
                        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                    }
                }
            }
        }
