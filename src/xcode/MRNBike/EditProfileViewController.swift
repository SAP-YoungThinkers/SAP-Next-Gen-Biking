

import Foundation
import UIKit

class EditProfileViewController : UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageBG: UIImageView!
    @IBOutlet weak var PrefStack: UIStackView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var userBar: UIView!
    @IBOutlet weak var scrollView : UIScrollView!
    
    /* =======================
     
     USER DATA
     
     - Surname
     - First Name
     - Email
     - Password, Password Repeat
     - Weight
     - Wheelsize
     - Image
     
     ======================= */
    
    //User Bar View
    var tmpPasswordHash : String!       // only local
    let imagePicker = UIImagePickerController()
    
    // options
    @IBOutlet weak var email : UILabel!
    @IBOutlet weak var password : UILabel!
    @IBOutlet weak var repeatPassword : UILabel!
    @IBOutlet weak var activityShare: UILabel!
    @IBOutlet weak var personalInfo: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var wheelSize: UILabel!
    
    // inputs
    @IBOutlet weak var inputEmail : UITextField!
    @IBOutlet weak var inputPassword : UITextField!
    @IBOutlet weak var inputPasswordRepeat : UITextField!
    @IBOutlet weak var inputActivity: UISwitch!
    @IBOutlet weak var inputIndicatorWeight: UILabel!
    @IBOutlet weak var inputWeight: UISlider!
    @IBOutlet weak var inputIndicatorWheel: UILabel!
    @IBOutlet weak var inputWheelSize: UISlider!
    
    
    var userBarViewController : UserBarViewController!
    let userBarSegueName = "userBarSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set save button disabled
        saveButton.isEnabled = false
        
        //Set text
        self.title = NSLocalizedString("editProfile", comment: "")
        email.text = NSLocalizedString("emailLabel", comment: "")
        password.text = NSLocalizedString("passwordLabel", comment: "")
        repeatPassword.text = NSLocalizedString("repeatPasswordLabel", comment: "")
        activityShare.text = NSLocalizedString("shareInfoLabel", comment: "")
        personalInfo.text = NSLocalizedString("personalInfoLabel", comment: "")
        weight.text = NSLocalizedString("weightLabel", comment: "")
        wheelSize.text = NSLocalizedString("wheelSizeLabel", comment: "")
        
        //Notification for keyboard will show/will hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //Delegation of the textFields to the view
        inputEmail.delegate=self
        inputPassword.delegate=self
        inputPasswordRepeat.delegate=self
        
        //Keyboard hides, whereever the user taps on the screen (except the keyboard)
        self.hideKeyboardWhenTappedAround()
        
        imagePicker.delegate = self
        
        // Change title color and font
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 20)!, NSForegroundColorAttributeName : UIColor.white]
        navBar.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 17)!], for: .normal)
        
        // Remove line and background
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // Blur Effect of Image Background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageBG.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.75
        imageBG.addSubview(blurEffectView)
        
        // user bar
        if let profileView : UIImageView = userBarViewController?.view.viewWithTag(1) as? UIImageView {
            profileView.layer.borderWidth = 2
            profileView.layer.masksToBounds = false
            profileView.layer.borderColor = UIColor.white.cgColor
            profileView.layer.cornerRadius = profileView.frame.height/2
            profileView.clipsToBounds = true
            
            // button over image
            let button = UIButton(type: .custom)
            button.frame = profileView.frame
            button.addTarget(self, action: #selector(handleImagePicker(button:)), for: .touchUpInside)
            userBarViewController.view.addSubview(button)
        }
        
        // surname
        if let surnameView : UILabel = userBarViewController?.view.viewWithTag(2) as? UILabel {
            surnameView.font = UIFont.init(name: "Montserrat-Regular", size: 16)!
            surnameView.numberOfLines = 0
            surnameView.sizeToFit()
        }
        
        // first name
        if let firstNameView : UILabel = userBarViewController?.view.viewWithTag(3) as? UILabel {
            firstNameView.font = UIFont.init(name: "Montserrat-Regular", size: 16)!
            firstNameView.numberOfLines = 0
            firstNameView.sizeToFit()
        }
        
        /*
         ========= USER OPTIONS =========
         */
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        // labels to fit size
        email.sizeToFit()
        password.sizeToFit()
        repeatPassword.sizeToFit()
        activityShare.sizeToFit()
        personalInfo.sizeToFit()
        inputIndicatorWeight.sizeToFit()
        weight.sizeToFit()
        inputIndicatorWheel.sizeToFit()
        wheelSize.sizeToFit()
        
        // Read user instance and set values
        let user = User.getUser()
        
        // surname input
        if let inputSurnameView = userBarViewController?.view.viewWithTag(4) as? UITextField {
            inputSurnameView.font = UIFont.init(name: "Montserrat-Light", size: 22)!
            inputSurnameView.text = user.surname
        }
        
        // first name input
        if let firstNameView = userBarViewController?.view.viewWithTag(5) as? UITextField {
            firstNameView.font = UIFont.init(name: "Montserrat-Light", size: 22)!
            firstNameView.text = user.firstName
        }
        
        //Set eMail
        if let userMail = KeychainService.loadEmail() {
            inputEmail.text = userMail as String
        }
        inputEmail.isUserInteractionEnabled = false
        
        //Set password
        if let tmpUserPass = KeychainService.loadPassword() as String? {
            inputPassword.text = tmpUserPass
            inputPasswordRepeat.text = tmpUserPass
        }
        
        //Set share option
        if user.shareInfo == 0 {
            inputActivity.isOn = false
        } else {
            inputActivity.isOn = true
        }
        
        //Set user weight
        inputWeight.value = Float(user.userWeight!)
        inputIndicatorWeight.text = "\(Int(inputWeight.value)) kg"
        inputIndicatorWeight.sizeToFit()
        
        //Set wheel size
        inputWheelSize.value = Float(user.userWheelSize!)
        inputIndicatorWheel.text = "\(Int(inputWheelSize.value)) Inches"
        inputIndicatorWheel.sizeToFit()
        
        //Set user image
        if let image = user.profilePicture {
            let img = UIImage(data: image)
            imageBG.image = img
            if let profileView : UIImageView = userBarViewController?.view.viewWithTag(1) as? UIImageView {
                profileView.image = img
            }
        }
        
        //Bind textfields to validator
        let surname = userBarViewController.view.viewWithTag(4) as! UITextField
        let firstname = userBarViewController.view.viewWithTag(5) as! UITextField
        surname.addTarget(self, action:#selector(EditProfileViewController.checkInput), for:UIControlEvents.editingChanged)
        firstname.addTarget(self, action:#selector(EditProfileViewController.checkInput), for:UIControlEvents.editingChanged)
        inputPassword.addTarget(self, action:#selector(EditProfileViewController.checkInput), for:UIControlEvents.editingChanged)
        inputPasswordRepeat.addTarget(self, action:#selector(EditProfileViewController.checkInput), for:UIControlEvents.editingChanged)
    }
    
    //Check if email, password, firstname and lastname are syntacticylly valid and TermSwitch is on
    func checkInput() {
        
        var valid = false
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[$@$!%*?&])(?=.*[0-9])(?=.*[a-z]).{10,15}$")
        let nameTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß\\s]{2,20}$")
        
        let surname = userBarViewController.view.viewWithTag(4) as! UITextField
        let firstname = userBarViewController.view.viewWithTag(5) as! UITextField
        
        //Check input fields and TermSwitcher
        if nameTest.evaluate(with: surname.text) && nameTest.evaluate(with: firstname.text) && passwordTest.evaluate(with: inputPassword.text) && passwordTest.evaluate(with: inputPasswordRepeat.text) {
            //Check if passwords are similar
            if inputPassword.text?.characters.count == inputPasswordRepeat.text?.characters.count {
                valid = true
            }
        }
        
        //If all inputs are valid, enable the done button
        if valid == true {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
    func handleImagePicker(button: UIButton) {
        print("image picked!")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == userBarSegueName {
            userBarViewController = segue.destination as? UserBarViewController
        }
    }
    
    func randomString(_ length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!§$"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
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
        for subview in imageBG.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
        imageBG.image = pickedImage
        
        // Blur Effect of Image Background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageBG.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.75
        
        imageBG.addSubview(blurEffectView)
        
        if let profileView : UIImageView = userBarViewController?.view.viewWithTag(1) as? UIImageView {
            profileView.image = pickedImage
        }
    }
    
    
    //Two functions for moving the screens content up so the keyboard doesn't mask the content and down
    func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    // MARK: Actions
    
    // save button pressed
    @IBAction func saveRequest(_ sender: UIBarButtonItem) {
        
        let passwordAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        
        if (inputPassword.text == inputPasswordRepeat.text) {
            
            if (inputPassword.text != tmpPasswordHash) {
                
                if (inputPassword.text != "") {
                    
                }
                else {
                    // password empty
                    passwordAlert.title = NSLocalizedString("passwordEmptyDialogTitle", comment: "")
                    passwordAlert.message = NSLocalizedString("passwordEmptyDialogMsg", comment: "")
                    passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: nil))
                    self.present(passwordAlert, animated: true, completion: nil)
                    print("password empty")
                    return
                }
            }
            else {
                // password not changed
                print("password didnt change, so wont be overwritten")
            }
        }
        else {
            // passwords dont match
            passwordAlert.title = NSLocalizedString("passwordMismatchDialogTitle", comment: "")
            passwordAlert.message = NSLocalizedString("passwordMismatchDialogMsg", comment: "")
            passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            print("passwords dont match")
            return
        }
        
        //Show activity indicator
        let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
        present(activityAlert, animated: false, completion: nil)
        
        let firstname = self.userBarViewController?.view.viewWithTag(5) as! UITextField
        let surname = self.userBarViewController?.view.viewWithTag(4) as! UITextField
        
        let user = User.getUser()
        
        var shareInfo = 0
        
        if inputActivity.isOn {
            shareInfo = 1
        }
        
        //Upload updated user to Hana
        let uploadData : [String: Any] = ["email" : inputEmail.text!, "password" : inputPassword.text!, "firstname" : firstname.text!, "lastname" : surname.text! , "allowShare" : shareInfo, "wheelsize" : Int(inputWheelSize.value), "weight" : Int(inputWeight.value), "burgersburned" : user.burgersBurned!, "wheelrotation" : user.wheelRotation!, "distancemade" : user.distanceMade!, "co2saved" : user.co2Saved!]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
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
                    user.surname = surname.text!
                    user.firstName = firstname.text!
                    user.userWeight = Int(self.inputWeight.value) //self.weightSlider.value //Change to int
                    user.userWheelSize = Int(self.inputWheelSize.value) //self.wheelSizeSlider.value
                    
                    user.shareInfo = shareInfo
                    
                    user.profilePicture = UIImageJPEGRepresentation(self.imageBG.image!, 1.0)
                    
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
    }
    
    // weight slider indicator update
    @IBAction func weightChanged(_ sender: UISlider) {
        inputIndicatorWeight.text = "\(Int(inputWeight.value)) kg"
        inputIndicatorWeight.sizeToFit()
    }
    
    // wheelsize slider indicator update
    @IBAction func wheelChanged(_ sender: UISlider) {
        inputIndicatorWheel.text = "\(Int(inputWheelSize.value)) Inches"
        inputIndicatorWheel.sizeToFit()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

class UserBarViewController: UIViewController {
    
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        surnameLabel.text = NSLocalizedString("surnameLabel", comment: "")
        firstnameLabel.text = NSLocalizedString("firstnameLabel", comment: "")
    }
}
