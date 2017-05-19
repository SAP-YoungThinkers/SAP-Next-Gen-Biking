//
//  FirstLogInViewController.swift
//  MRNBike
//
//  Created by 1 on 04.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class FirstLogInViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
  
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var messageLabelTextField: UILabel!
    @IBOutlet private var helpView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
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
        
        if defaults.object(forKey: "userName") != nil {
            passwordWasStored = true
        }
        rememberSwitch.isOn = passwordWasStored
        

        if passwordWasStored {
            userEmailTextField.text = defaults.object(forKey: "userName") as! String?
            userPasswordTextField.text = defaults.object(forKey: "userPassword") as! String?
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
     
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        
        let login = UserDefaults.standard.string(forKey: "userMail")
        let pass = UserDefaults.standard.string(forKey: "userPassword")
        
        let passwordAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)

       
            
            //Checking if Remember Password is on: Login with default values saved.
       if rememberSwitch.isOn {
        if userEmailTextField != nil && userPasswordTextField != nil {
            defaults.set(userEmailTextField.text, forKey: "userName")
            defaults.set(userPasswordTextField.text, forKey: "userPassword")
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(controller, animated: true, completion: nil)
            
        }
    }
            //Check if Remember Password is Off, Check for other conditions to Login
    
       else if passwordWasStored && rememberSwitch.isOn == false {
        
        
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "userPassword")
        
    
    if login != nil && login == userEmail  {
        
            if pass == userPassword{
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "Home")
                self.present(controller, animated: true, completion: nil)
                
            }
                
            else {
              
                passwordAlert.title = "Password wrong"
                passwordAlert.message = "Please fill in your password"
                passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                self.present(passwordAlert, animated: true, completion: nil)
                print("Password is wrong")
                return
            }
    }
    

        else {
           
            passwordAlert.title = "User doesn't exist"
            passwordAlert.message = "Please check a correctness of your email!"
            passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            print("User doesn't exist")
            return
        }
            }
        
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
