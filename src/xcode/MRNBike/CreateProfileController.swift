import UIKit

class CreateProfileController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    
    
    @IBOutlet weak var surnameDescription: UILabel!
    @IBOutlet weak var firstnameDescription: UILabel!
    @IBOutlet weak var emailDescription: UILabel!
    @IBOutlet weak var passwodDescription: UILabel!
    @IBOutlet weak var repeatPasswordDescription: UILabel!
    @IBOutlet weak var activityShareDescription: UILabel!
    @IBOutlet weak var agreementTermCondition: UILabel!
    @IBOutlet weak var personalInfoLabel: UILabel!
    
    @IBOutlet private(set) var surnameLabel: UITextField!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet private(set) var emailLabel: UITextField!
    @IBOutlet private(set) var passwordLabel: UITextField!
    @IBOutlet private(set) var confirmPasswordLabel: UITextField!
    @IBOutlet private(set) var shareSwitch: UISwitch!
    
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var wheelSize: UILabel!
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var weightUnity: UILabel!
    @IBOutlet weak var wheelSizeInput: UITextField!
    @IBOutlet weak var wheelSizeUnity: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var imagePickerButton: UIButton!
    
    @IBOutlet var termSwitch: UISwitch!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet weak var tableCellPassword: UITableViewCell!
    @IBOutlet weak var passwordHint: UILabel!
    @IBOutlet weak var passwordRepeatHint: UILabel!
    
    @IBAction func wheelInputChanged(_ sender: Any) {
        guard let tf = sender as? UITextField else {
            checkInput()
            return
        }
        var array: [Character] = Array(tf.text!.characters)
        var decimalCount = 0
        var numberStarts = false
        for character in array {
            if numberStarts {
                decimalCount += 1
            }
            if character == "." || character == "," {
                numberStarts = true
            }
        }
        
        if decimalCount > 1 {
            _ = array.popLast()
            tf.text = String(array)
        }
        if tf.text! == "." || tf.text! == "," {
            tf.text = "0."
        }
        checkInput()
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        self.title = NSLocalizedString("createProfile", comment: "")
        surnameDescription.text = NSLocalizedString("surnameLabel", comment: "")
        firstnameDescription.text = NSLocalizedString("firstnameLabel", comment: "")
        emailDescription.text = NSLocalizedString("emailLabel", comment: "")
        passwodDescription.text = NSLocalizedString("passwordLabel", comment: "")
        repeatPasswordDescription.text = NSLocalizedString("repeatPasswordLabel", comment: "")
        activityShareDescription.text = NSLocalizedString("shareInfoLabel", comment: "")
        agreementTermCondition.text = NSLocalizedString("agreeTermCondition", comment: "")
        personalInfoLabel.text = NSLocalizedString("personalInfoLabel", comment: "")
        
        weight.text = NSLocalizedString("weightLabel", comment: "")
        wheelSize.text = NSLocalizedString("wheelSizeLabel", comment: "")
        weightUnity.text = "kg"
        wheelSizeUnity.text = NSLocalizedString("weightUnity", comment: "")
        
        surnameLabel.placeholder = NSLocalizedString("surnameLabel", comment: "")
        firstNameLabel.placeholder = NSLocalizedString("firstnameLabel", comment: "")
        emailLabel.placeholder = NSLocalizedString("emailExample", comment: "")
        passwordLabel.placeholder = NSLocalizedString("passwordLabel", comment: "")
        confirmPasswordLabel.placeholder = NSLocalizedString("repeatPasswordLabel", comment: "")
        
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
        
        //Set done button disabled
        doneButton.isEnabled = false
        
        //Bind textfields and self.termSwitch to validator
        surnameLabel.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        firstNameLabel.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        emailLabel.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        passwordLabel.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        confirmPasswordLabel.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        self.termSwitch.addTarget(self, action: #selector(CreateProfileController.checkInput), for: UIControlEvents.valueChanged)
        
        /* Password Hints */
        passwordLabel.addTarget(self, action: #selector(CreateProfileController.passwordValidate), for: UIControlEvents.editingDidEnd)
        confirmPasswordLabel.addTarget(self, action: #selector(CreateProfileController.passwordRepeatValidate), for: UIControlEvents.editingDidEnd)
        
        passwordHint.isHidden = false
        passwordHint.text = NSLocalizedString("passwordValidationHint", comment: "")
        passwordRepeatHint.isHidden = true
        passwordRepeatHint.text = NSLocalizedString("passwordRepeatValidationHint", comment: "")
    }
    
    func passwordValidate() {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,25}$")
        
        if passwordTest.evaluate(with: passwordLabel.text) {
            passwordHint.isHidden = false
            return
        }
        passwordHint.isHidden = false
    }
    
    func passwordRepeatValidate() {
        if passwordLabel.text == confirmPasswordLabel.text {
            passwordRepeatHint.isHidden = true
            return
        }
        passwordRepeatHint.isHidden = false
    }
    
    @IBAction func doneOnPressed(_ sender: UIBarButtonItem) {
        
        //Show alert that passwords are not similar
        if(passwordLabel.text != confirmPasswordLabel.text) {
            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("passwordMismatchDialogTitle", comment: ""), message: NSLocalizedString("passwordMicmatchDialogMsg", comment: "")), animated: true, completion: nil)
            doneButton.isEnabled = false
            return
        }
        
        //Show activity indicator
        let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
        present(activityAlert, animated: false, completion: nil)
        
         var shareInfo = 0
        
        if shareSwitch.isOn {
            shareInfo = 1
        }
        
        //Collect data for creating user        
        var numberDouble = wheelSizeInput.text!.doubleValue
        if numberDouble == nil {
            numberDouble = 0.0
        }
        /* CONVERT TO INT BY MULTIPLYING WITH 10 */
        let number = Int(numberDouble! * 10.0)
        
        let uploadData : [String: Any] = ["email" : emailLabel.text!, "password" : passwordLabel.text!, "firstname" : firstNameLabel.text!, "lastname" : surnameLabel.text!, "allowShare" : shareInfo, "wheelsize" : number, "weight" : Int(weightInput.text!)!, "burgersburned": 0.0,
            "wheelrotation": 0, "distancemade": 0.0, "co2Type": "car"]
        print(uploadData)
        
        //Generate json data for upload
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
        //Try create user in backend
        ClientService.postUser(scriptName: "createUser.xsjs", userData: jsonData) { (httpCode, error) in
            
            if error == nil {

                switch httpCode! {
                case 200: //User created
                    
                    //Save email and password in KeyChain
                    KeychainService.saveEmail(token: self.emailLabel.text! as NSString)
                    KeychainService.savePassword(token: self.passwordLabel.text! as NSString)
                    
                    User.createSingletonUser(userData: nil)
                    let user = User.getUser()
                    user.firstName = self.firstNameLabel.text
                    user.surname = self.surnameLabel.text
                    user.userWeight = Int(self.weightInput.text!)
                    user.userWheelSize = number
                    
                    user.shareInfo = shareInfo
                    
                    if let tmpPhoto = self.photoImageView.image {
                        user.profilePicture = UIImageJPEGRepresentation(tmpPhoto, 1.0)  // get image data
                    }
                    user.burgersBurned = 0.0
                    user.wheelRotation = 0
                    user.distanceMade = 0.0
                    user.co2Type = User.co2ComparedObject.car
                    
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false, completion: nil)
                    
                    self.view.endEditing(true)
                    
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "Home")
                    self.present(controller, animated: true, completion: nil)
                    self.close()
                    break
                case 409: //User already exists
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false, completion: nil)
                    
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("userExistsDialogTitle", comment: ""), message: NSLocalizedString("userExistsDialogMsg", comment: "")), animated: true, completion: nil)
                    self.doneButton.isEnabled = false
                    break
                default: //For http error codes: 500
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false, completion: nil)
                    
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                    self.doneButton.isEnabled = false
                    return
                }
            }
            else
            {
                //Dismiss activity indicator
                activityAlert.dismiss(animated: false, completion: nil)
                
                //An error occured in the app
                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                self.doneButton.isEnabled = false
            }
        }
    }
    
    // MARK: - Switch action
    
    @IBAction func openTerm(_ sender: Any) {
        guard self.termSwitch.isOn else { return }
        
        let storyboard = UIStoryboard(name: "StartPage", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "TermScene") as? TermConditionsViewController {
            
            controller.complete = {
                self.termSwitch.isOn = false
            }
            
            self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(controller, animated: true, completion:nil)
        }
    }
    
    // MARK: -
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        print("image is going to be picked!")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Check if email, password, firstname and lastname are syntacticylly valid and TermSwitch is on
    func checkInput() {
        
        var valid = false
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Z0-9a-z.-_]+\\.[A-Za-z]{2,5}")
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,25}$")
        let nameTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß\\s]{2,20}$")
        
        //Check input fields and TermSwitcher
        if nameTest.evaluate(with: surnameLabel.text) && nameTest.evaluate(with: firstNameLabel.text) &&  emailTest.evaluate(with: emailLabel.text) && passwordTest.evaluate(with: passwordLabel.text) && passwordTest.evaluate(with: confirmPasswordLabel.text) && self.termSwitch.isOn {
            
            //Check if passwords are similar
            if passwordLabel.text?.characters.count == confirmPasswordLabel.text?.characters.count  {
                if wheelSizeInput.text!.doubleValue != nil && Int(weightInput.text!) != nil {
                    valid = true
                }
            }
        }
        
        doneButton.isEnabled = valid
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

extension String {
    // because of seperators like "." or ","
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double? {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return nil
    }
}
