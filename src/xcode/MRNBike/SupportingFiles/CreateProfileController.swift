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

  /*  //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions

    
    @IBAction func avatarButtonPressed(_ sender: UITapGestureRecognizer) {
        //TODO: code for select userpic
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    } */
    
    // Slider value changes
    @IBOutlet private(set) var currentWeightLabel: UILabel!
    
    @IBAction func weightSliderValueChanged(_ sender: UISlider) {
        var currentWeight = Int (sender.value)
        currentWeightLabel.text = "\(currentWeight) " + " kg"
    }

    @IBOutlet private(set) var currentWheelSize: UILabel!
    
    @IBAction func wheelSliderValueChanged(_ sender: UISlider) {
        var currentWheel = Int (sender.value)
        currentWheelSize.text = "\(currentWheel) " + " inch"
        
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
