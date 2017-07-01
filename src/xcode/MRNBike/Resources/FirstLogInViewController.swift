import UIKit

class FirstLogInViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var messageLabelTextField: UILabel!
    @IBOutlet private var helpView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberPasswordLabel: UILabel!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    
    // Default user
    // let defaultUserName = "Ziad"
    // let defaultPassword = "123"
    
    var defaults = UserDefaults.standard
    var passwordWasStored: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        self.title = NSLocalizedString("signIn", comment: "")
        userEmailTextField.placeholder = NSLocalizedString("emailLabel", comment: "")
        userPasswordTextField.placeholder = NSLocalizedString("passwordLabel", comment: "")
        rememberPasswordLabel.text = NSLocalizedString("rememberPassword", comment: "")
        loginButton.setTitle(NSLocalizedString("loginButton", comment: ""), for: .normal)
        registerButton.setTitle(NSLocalizedString("registerButton", comment: ""), for: .normal)
        
        //Hide Keyboard Extension
        self.hideKeyboardWhenTappedAround()
        self.userEmailTextField.delegate = self
        self.userPasswordTextField.delegate = self
        
        //Bind textfields to regex validator
        userEmailTextField.addTarget(self, action:#selector(FirstLogInViewController.checkRegEx), for:UIControlEvents.editingChanged)
        userPasswordTextField.addTarget(self, action:#selector(FirstLogInViewController.checkRegEx), for:UIControlEvents.editingChanged)
        
        if defaults.object(forKey: "rememberMe") != nil{
            passwordWasStored = defaults.object(forKey: "rememberMe") as! Bool
        }
        rememberSwitch.isOn = passwordWasStored
        
        if passwordWasStored {
            if let userName = KeychainService.loadEmail() {
                userEmailTextField.text = userName as String
            }
            if let userPassword = KeychainService.loadPassword() {
                userPasswordTextField.text = userPassword as String
            }
        }
        
        // Change title color and font
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 20)!, NSForegroundColorAttributeName : UIColor.black]
        
        // Setting default values for Login button incase of Remembering Password is on or off.
        if !rememberSwitch.isOn{
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        }
        else {
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
        }
    }
    
    //Check if email and password are syntacticylly valid
    func checkRegEx() {
        
        var valid = false
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[$@$!%*?&])(?=.*[0-9])(?=.*[a-z]).{10,15}$")
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Z0-9a-z.-_]+\\.[A-Za-z]{2,3}")
    
        if emailTest.evaluate(with: userEmailTextField.text) && passwordTest.evaluate(with: userPasswordTextField.text) {
            valid = true
            print("true")
        }
       
        if valid == true {
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
            print("false")
        }
    }
    
    // Login to the app
    @IBAction func onPressedLogin(_ sender: UIButton) {
        let passwordAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        
        if !rememberSwitch.isOn {
            defaults.set(false, forKey: "rememberMe")
        }
        
        //Check if user exists in Hana
        let uploadData : [String: Any] = ["email" : userEmailTextField.text!, "password" : userPasswordTextField.text!]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
        var response = StorageHelper.prepareUploadUser(scriptName: "user/verifyUser.xsjs", data: jsonData)
        
        let code = response["code"] as! Int
        
        switch code {
        case 201:
            // cachse default user
            if rememberSwitch.isOn {
                defaults.set(true, forKey: "rememberMe")
            }
            defaults.set(false, forKey: StorageKeys.shouldLoginKey)
            
            //Save email and password to keychain
            KeychainService.saveEmail(token: userEmailTextField.text! as NSString)
            KeychainService.savePassword(token: userPasswordTextField.text! as NSString)
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            User.getUser(mail: userEmailTextField.text!)
            self.present(controller, animated: true, completion: nil)
            print("User verified.")
            break
        case 0:
            print("No JSON data in the body.")
            break
        case 400:
            print("Invalid JSON.")
            break
        case 404:
            passwordAlert.title = NSLocalizedString("passwordUserWrongDialogTitle", comment: "")
            passwordAlert.message = NSLocalizedString("passwordUserDialogMsg", comment: "")
            passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            break
        default:
            print("Error")
        }
    }
    
    // MARK: Actions
    
    //Open a help message
    @IBAction func openHelpMessage(_ sender: UIButton) {
        self.helpView.isHidden = !self.helpView.isHidden
    }
    
    // Close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
