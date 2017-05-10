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

    
    
    @IBOutlet weak var photoImageView: UIImageView!

    
    // Slider value changes
    @IBOutlet private(set) var currentWeightLabel: UILabel!
    
    @IBAction func weightSliderValueChanged(_ sender: UISlider) {
        let currentWeight = Int (sender.value)
        currentWeightLabel.text = "\(currentWeight) " + " kg"
    }

    @IBOutlet private(set) var currentWheelSize: UILabel!
    
    @IBAction func wheelSliderValueChanged(_ sender: UISlider) {
        let currentWheel = Int (sender.value)
        currentWheelSize.text = "\(currentWheel) " + " Inches"
        
    }

    @IBAction func doneOnPressed(_ sender: UIBarButtonItem) {
        let user = User()
        
        // Check passwords
        if(passwordLabel.text == confirmPasswordLabel.text){
            user.accountPassword = passwordLabel.text
        } else {
            //user.accountPassword = nil
            // TODO show alert "different passwords"
        }
        
        user.accountSurname = surnameLabel.text
        user.accountFirstName = firstNameLabel.text
        user.accountName = emailLabel.text
        user.accountShareInfo = shareSwitch.isOn
        user.accountUserWeight = weightSlider.value
        user.accountUserWheelSize = wheelSizeSlider.value
        
        UserDefaults.standard.set(user.accountSurname, forKey: "userSurname")
        UserDefaults.standard.set(user.accountFirstName, forKey: "userFirstname")
        UserDefaults.standard.set(user.accountName, forKey: "userAccount")
        UserDefaults.standard.set(user.accountPassword, forKey: "userPassword")
        UserDefaults.standard.set(user.accountShareInfo, forKey: "userShareInfo")
        UserDefaults.standard.set(user.accountUserWeight, forKey: "userWeight")
        UserDefaults.standard.set(user.accountUserWheelSize, forKey: "userSize")
        
        self.view.endEditing(true)
        self.close()
 
    }


    
}
