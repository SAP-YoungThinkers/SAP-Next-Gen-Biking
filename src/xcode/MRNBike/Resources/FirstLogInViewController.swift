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
        
        if !rememberSwitch.isOn {
            defaults.set(false, forKey: "rememberMe")
        }
        
        //Check if user exists in Hana
        let uploadData : [String: Any] = ["email" : userEmailTextField.text!, "password" : userPasswordTextField.text!]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
        ClientService.postUser(scriptName: "user/verifyUser.xsjs", userData: jsonData) { (httpCode, error) in
            if error == nil {
                
                let code = httpCode!
                
                switch code {
                case 201: //User verified
                    // cachse default user
                    if self.rememberSwitch.isOn {
                        self.defaults.set(true, forKey: "rememberMe")
                    }
                    self.defaults.set(false, forKey: StorageKeys.shouldLoginKey)
                    
                    //Save email and password to keychain
                    KeychainService.saveEmail(token: self.userEmailTextField.text! as NSString)
                    KeychainService.savePassword(token: self.userPasswordTextField.text! as NSString)
                    
                    
                    ClientService.getUser(mail: self.userEmailTextField.text!, completion: { (data, error) in
                        if error == nil {
                            
                            guard let responseData = data else {
                                //An error occured
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                                return
                            }
                            
                            User.createSingletonUser(userData: responseData)
                            let user = User.getUser()
                            print(user)
                            
                            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
                            self.present(controller, animated: true, completion: nil)
                        } else {
                            //An error occured
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        }
                    })
                    break
                case 404: //Username/Password wrong ot user doesn't exists
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("passwordUserWrongDialogTitle", comment: ""), message: NSLocalizedString("passwordUserDialogMsg", comment: "")), animated: true, completion: nil)
                    break
                default: //JSON wrong or empty (Code 0, 400 or 500)
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
