        
        
        import UIKit
        
        class SettingsViewController: UIViewController   {
            
            @IBOutlet weak var busButton: UIButton!
            @IBOutlet weak var trainButton: UIButton!
            @IBOutlet weak var CarButton: UIButton!
            
            var tempstate: UIControlState = []
            let selcolor = UIColor(hexString: "27AE60")
            
            override func viewDidLoad() {
                super.viewDidLoad()
                
                let image1Clicked = UITapGestureRecognizer(target: self, action: #selector(imageFunc1(tabgesture:)))
                image1.addGestureRecognizer(image1Clicked)
                
                // Identify setted object
                let user = User.getUser()
                
                if let co2Choice = user.co2Choice {
                    switch co2Choice {
                    case 133:
                         CarButton.setBackgroundImage(#imageLiteral(resourceName: "Car"), for: tempstate)
                         CarButton.borderWidth = 2
                         CarButton.borderColor = selcolor
                                                //user.co2Emissions
                    case 69:
                        trainButton.setBackgroundImage(#imageLiteral(resourceName: "Train"), for: tempstate)
                        trainButton.borderWidth = 2
                        trainButton.borderColor = selcolor
                    case 65:
                        busButton.setBackgroundImage (#imageLiteral(resourceName: "Bus"), for: tempstate)
                        busButton.borderWidth = 2
                        busButton.borderColor = selcolor
                    default:
                        CarButton.setBackgroundImage(#imageLiteral(resourceName: "Car"), for: tempstate)
                        CarButton.borderWidth = 2
                        CarButton.borderColor = selcolor
                    }
                }
                else {
                    CarButton.setBackgroundImage(#imageLiteral(resourceName: "Car"), for: tempstate)
                    CarButton.borderWidth = 2
                    CarButton.borderColor = selcolor
                }
            
            }
            
            func imageFunc1(tabgesture : UITapGestureRecognizer) {
                let tappedImage = tabgesture.view as! UIImageView
            }
            
            @IBAction func carObject_press(_ sender: Any) {
                let user = User.getUser()
                user.co2Emissions = 0.133 // hardcode for co2ComparedObject.train
                let co2Choice = "133"
                CarButton.setBackgroundImage(#imageLiteral(resourceName: "Car"), for: tempstate)
                trainButton.setBackgroundImage(#imageLiteral(resourceName: "TrainBlack"), for: tempstate)
                busButton.setBackgroundImage(#imageLiteral(resourceName: "BusBlack"), for: tempstate)
                //user.co2Emissions = User.co2ComparedObject.car
                CarButton.borderWidth = 2
                CarButton.borderColor = selcolor
                trainButton.borderWidth = 0
                busButton.borderWidth = 0
                CO2HANASend() // update user info at backend
                
            }
            @IBOutlet weak var image1: UIImageView!
            
            @IBAction func trainObject_press(_ sender: Any) {
                let user = User.getUser()
                user.co2Emissions = 0.069 // hardcode for co2ComparedObject.train
                let co2Choice = "69"
                CO2HANASend() // update user info at backend
                CarButton.setBackgroundImage(#imageLiteral(resourceName: "CarBlack"), for: tempstate)
                trainButton.setBackgroundImage(#imageLiteral(resourceName: "Train"), for: tempstate)
                busButton.setBackgroundImage(#imageLiteral(resourceName: "BusBlack"), for: tempstate)
                //user.co2Emissions = User.co2ComparedObject.train
                trainButton.borderWidth = 2
                trainButton.borderColor = selcolor
                CarButton.borderWidth = 0
                busButton.borderWidth = 0
            }
            
            @IBAction func busObject_press(_ sender: Any) {
                let user = User.getUser()
                user.co2Emissions = 0.065 // hardcode for co2ComparedObject.bus
                let co2Choice = "65"
                CO2HANASend() // update user info at backend
                CarButton.setBackgroundImage(#imageLiteral(resourceName: "CarBlack"), for: tempstate)
                trainButton.setBackgroundImage(#imageLiteral(resourceName: "TrainBlack"), for: tempstate)
                busButton.setBackgroundImage (#imageLiteral(resourceName: "Bus"), for: tempstate)
                //user.co2Emissions = User.co2ComparedObject.bus
                busButton.borderWidth = 2
                busButton.borderColor = selcolor
                trainButton.borderWidth = 0
                CarButton.borderWidth = 0
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
             func CO2HANASend () {
                
                // update user info at backend
                //Upload updated user to Hana
                //let uploadData : [String: Any] = [
                    /*
                     "email" : firstname.text!, "password" : inputPassword.text!, "firstname" : firstname.text!, "lastname" : surname.text! , "allowShare" : shareInfo, "wheelsize" : Int(inputWheelSize.value), "weight" : Int(inputWeight.value), "burgersburned" : user.burgersBurned!, "wheelrotation" : user.wheelRotation!, "distancemade" : user.distanceMade!, "co2saved" : user.co2Saved!,
                     */
                   // "co2Emissions" : "car"]
                
                /*    let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
                 
                 //Try update user profile
                 ClientService.postUser(scriptName: "updateUser.xsjs", userData: jsonData) { (httpCode, error) in
                 if error == nil {
                 
                 switch httpCode! {
                 case 200: //User successfully updated
                 
                 //Save email and password in KeyChain
                 if let mail = self.inputEmail.text as NSString? {
                 KeychainService.saveEmail(token: mail)
                 }
                 if let password = self.inputPassword.text as NSString? {
                 KeychainService.savePassword(token: password)
                 }
                 
                 //Update User class
                 let user = User.getUser()
                 user.co2Emissions = 0.133 // hardcode for co2ComparedObject.car
                 
                 //Dismiss activity indicator
                 activityAlert.dismiss(animated: false, completion: nil)
                 
                 let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("userUpdatedDialogTitle", comment: ""), message: NSLocalizedString("userUpdatedDialogMsg", comment: ""))
                 let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                 (action) -> Void in self.navigationController?.popViewController(animated: true)
                 })
                 alert.addAction(gotItAction)
                 self.present(alert, animated: true, completion: nil)
                 break
                 default: //For http error codes: 500
                 //Dismiss activity indicator
                 activityAlert.dismiss(animated: false, completion: nil)
                 
                 let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: ""))
                 let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                 (action) -> Void in self.navigationController?.popViewController(animated: true)
                 })
                 alert.addAction(gotItAction)
                 self.present(alert, animated: true, completion: nil)
                 }
                 }
                 else
                 {
                 //Dismiss activity indicator
                 activityAlert.dismiss(animated: false, completion: nil)
                 
                 //An error occured in the app
                 self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                 }
                 }
                 */
            }
        }
