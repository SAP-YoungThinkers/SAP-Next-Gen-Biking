

import UIKit

class FirstLogInViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var messageLabelTextField: UILabel!
    @IBOutlet private var helpView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
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
        
        self.userEmailTextField.delegate = self
        self.userPasswordTextField.delegate = self
        
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
        // Setting Fields to trigger any Changes
        userEmailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        userPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
            passwordAlert.title = "Username/Password is wrong"
            passwordAlert.message = "Please check your username/password"
            passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            print("User not found.")
            break
        default:
            print("Error")
        }

        /*
        // validate user inputs 
        if (userEmailTextField.text == defaultUserName && userPasswordTextField.text == defaultPassword) {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(controller, animated: true, completion: nil)
        } else {
            if userPasswordTextField.text != defaultPassword && userEmailTextField.text == defaultUserName {
                passwordAlert.title = "Password wrong"
                passwordAlert.message = "Please fill in your password"
                passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                self.present(passwordAlert, animated: true, completion: nil)
            } else {
                passwordAlert.title = "User doesn't exist"
                passwordAlert.message = "Please check a correctness of your email!"
                passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                self.present(passwordAlert, animated: true, completion: nil)
            }
 }
 */
        
    }
    
    // UITextFieldDelegate For Enablind/Disabling Login Button
    
    func textFieldDidChange(_ textField: UITextField) {
        loginButton.isEnabled = (userEmailTextField.text != "") && (userPasswordTextField.text != "")
        if loginButton.isEnabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
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
