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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change title color and font
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 20)!, NSForegroundColorAttributeName : UIColor.black]
        
    }
    // Login to the app
    @IBAction func onPressedLogin(_ sender: UIButton) {
     
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        
        let login = UserDefaults.standard.string(forKey: "userMail")
        let pass = UserDefaults.standard.string(forKey: "userPassword")
        
        let passwordAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)

        
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
