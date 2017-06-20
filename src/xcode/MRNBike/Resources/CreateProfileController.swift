import UIKit

class CreateProfileController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    
    @IBOutlet private(set) var surnameLabel: UITextField!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet private(set) var emailLabel: UITextField!
    @IBOutlet private(set) var passwordLabel: UITextField!
    @IBOutlet private(set) var confirmPasswordLabel: UITextField!
    @IBOutlet private(set) var shareSwitch: UISwitch!
    @IBOutlet private(set) var weightSlider: UISlider!
 
    
    @IBOutlet private(set) var wheelSizeSlider: UISlider!

    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var imagePickerButton: UIButton!
    
    @IBOutlet var TemSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // delegate for hiding keyboard
        surnameLabel.delegate = self
        firstNameLabel.delegate = self
        emailLabel.delegate = self
        passwordLabel.delegate = self
        confirmPasswordLabel.delegate = self
        
        //Hide Keyboard Extension
        self.hideKeyboardWhenTappedAround()
        
        // Change title color and font
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 20)!, NSForegroundColorAttributeName : UIColor.black]
        navBar.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 17)!], for: .normal)
        
        // set defaults
        currentWeightLabel.text = "\(Int(weightSlider.value)) " + " kg"
        currentWeightLabel.sizeToFit()
        currentWheelSize.text = "\(Int(wheelSizeSlider.value)) " + " Inches"
        currentWheelSize.sizeToFit()
    }

    
    // Slider value changes
    @IBOutlet private(set) var currentWeightLabel: UILabel!
    
    @IBAction func weightSliderValueChanged(_ sender: UISlider) {
        let currentWeight = Int (sender.value)
        currentWeightLabel.text = "\(currentWeight) " + " kg"
        currentWeightLabel.sizeToFit()
    }

    @IBOutlet private(set) var currentWheelSize: UILabel!
    
    @IBAction func wheelSliderValueChanged(_ sender: UISlider) {
        let currentWheel = Int (sender.value)
        currentWheelSize.text = "\(currentWheel) " + " Inches"
        currentWheelSize.sizeToFit()
    }

    @IBAction func doneOnPressed(_ sender: UIBarButtonItem) {
        let user = User()
        
        // Check passwords
        let passwordAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        let termAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        
        
          //Agree with term condition warning
        if TemSwitch.isOn == false {
            termAlert.title = "Not accepted term conditions"
            termAlert.message = "Accept term conditions, please!"
            termAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(termAlert, animated: true, completion: nil)
            return
        
        }
        
        // username neccessary
        if (emailLabel.text == "") {
            print("E-Mail empty")
            passwordAlert.title = "No username"
            passwordAlert.message = "Please let us know your email!"
            passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            return
        }
        
        if(passwordLabel.text == confirmPasswordLabel.text) {
            if (passwordLabel.text != "") {
                user.accountPassword = passwordLabel.text
            }
            else {
                // empty password
                passwordAlert.title = "Password empty"
                passwordAlert.message = "Please fill in your password"
                passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                self.present(passwordAlert, animated: true, completion: nil)
                print("password empty")
                return
            }
        } else {
            // different passwords
            passwordAlert.title = "Password Mismatch"
            passwordAlert.message = "Please repeat the same password!"
            passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            print("passwords dont match")
            return
        }
        
        user.accountSurname = surnameLabel.text
        user.accountFirstName = firstNameLabel.text
        user.accountName = emailLabel.text
        user.accountShareInfo = shareSwitch.isOn
        user.accountUserWeight = weightSlider.value
        user.accountUserWheelSize = wheelSizeSlider.value
        if let tmpPhoto = photoImageView.image {
            user.accountProfilePicture = UIImageJPEGRepresentation(tmpPhoto, 1.0)  // get image data
        }
        
        //Save email and password in KeyChain
        KeychainService.saveEmail(token: emailLabel.text! as NSString)
        KeychainService.savePassword(token: passwordLabel.text! as NSString)
        
        let uploadData : [String: Any] = ["email" : KeychainService.loadEmail()!, "password" : KeychainService.loadPassword()!, "firstname" : firstNameLabel.text!, "lastname" : surnameLabel.text!, "allowShare" : shareSwitch.isOn, "wheelsize" : wheelSizeSlider.value, "weight" : weightSlider.value]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
        var response = StorageHelper.prepareUploadUser(scriptName: "user/createUser.xsjs", data: jsonData)
        
        let code = response["code"] as! Int
        
        switch code {
        case 201:
            print("User successfully created on Hana.")
            break
        case 0:
            print("No JSON data in the body.")
            break
        case 400:
            print("Invalid JSON.")
            break
        case 409:
            print("User already exists.")
            break
        default:
            print("Error")
        }
        
        UserDefaults.standard.set(user.accountSurname, forKey: StorageKeys.nameKey)
        UserDefaults.standard.set(user.accountFirstName, forKey: StorageKeys.firstnameKey)
        UserDefaults.standard.set(user.accountShareInfo, forKey: StorageKeys.shareKey)
        UserDefaults.standard.set(user.accountUserWeight, forKey: StorageKeys.weightKey)
        UserDefaults.standard.set(user.accountUserWheelSize, forKey: StorageKeys.wheelKey)
        UserDefaults.standard.set(user.accountProfilePicture, forKey: StorageKeys.imageKey)
        
 
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "Home")
        self.present(controller, animated: true, completion: nil)
        
        self.view.endEditing(true)
        self.close()
    }
    

    @IBAction func openTerm(_ sender: Any) {
        if TemSwitch.isOn == true {
        let storyboard = UIStoryboard(name: "StartPage", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "Term")
        self.present(controller, animated: true, completion: nil)
        }
        
    }


    @IBAction func imageButtonPressed(_ sender: UIButton) {
        print("image is going to be picked!")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            updateProfileBG(pickedImage: pickedImage)
        } else {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func updateProfileBG(pickedImage: UIImage) {
        
        // remove old blur first
        for subview in photoImageView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
        photoImageView.image = pickedImage
        
        // Blur Effect of Image Background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = photoImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.85
        
        photoImageView.addSubview(blurEffectView)
        
        imagePickerButton.backgroundColor = UIColor(red: (228/255.0), green: (228/255.0), blue: (228/255.0), alpha: 0.0)
        
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
