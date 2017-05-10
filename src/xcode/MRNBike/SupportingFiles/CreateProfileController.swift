import UIKit

class CreateProfileController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet private(set) var surnameLabel: UITextField!
    @IBOutlet private(set) var firstNameLabel: UITextField!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // Change title color and font
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 20)!, NSForegroundColorAttributeName : UIColor.white]
        navBar.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 17)!], for: .normal)
        
        // Remove background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // set defaults
        currentWeightLabel.text = "\(weightSlider.value) " + " kg"
        currentWeightLabel.sizeToFit()
        currentWheelSize.text = "\(wheelSizeSlider.value) " + " Inches"
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
        user.accountProfilePicture = UIImageJPEGRepresentation(photoImageView.image!, 1.0)  // get image data
        
        UserDefaults.standard.set(user.accountSurname, forKey: "userSurname")
        UserDefaults.standard.set(user.accountFirstName, forKey: "userFirstName")
        UserDefaults.standard.set(user.accountName, forKey: "userMail")
        UserDefaults.standard.set(user.accountPassword, forKey: "userPassword")
        UserDefaults.standard.set(user.accountShareInfo, forKey: "userShareActivity")
        UserDefaults.standard.set(user.accountUserWeight, forKey: "userWeight")
        UserDefaults.standard.set(user.accountUserWheelSize, forKey: "userWheelSize")
        UserDefaults.standard.set(user.accountProfilePicture, forKey: "userProfileImage")
        
        self.view.endEditing(true)
        self.close()
 
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
}
