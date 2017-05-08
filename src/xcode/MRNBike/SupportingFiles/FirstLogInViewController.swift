//
//  FirstLogInViewController.swift
//  MRNBike
//
//  Created by 1 on 04.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class FirstLogInViewController: UIViewController {
  
    @IBOutlet weak var userEmailTextField: UITextField!
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var messageLabelTextField: UILabel!
    
    @IBOutlet private var helpView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
  /*  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    } */
    //AMRK: - Handlers
    
    @IBAction func onPressedLogin(_ sender: UIButton) {
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text

        let userDictionary = UserDefaults.standard.object(forKey: "userTable") as? Dictionary<String,User>
        
       if userDictionary != nil {
            let user = userDictionary![userEmail!]
            messageLabelTextField.text = "1"
            if user != nil {
                messageLabelTextField.text = "2"
                if user?.accountPassword == userPassword {
                    messageLabelTextField.text = "3"
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                    self.present(controller, animated: true, completion: nil)
                    messageLabelTextField.text = "4"
                    
                }
                else {
                    messageLabelTextField.text = "5"
                //TODO add showing alert "The password is wrong. Check spelling"
                }
            }
            else {
                //messageLabelTextField.text = "6"
                //TODO add showing alert "No such user"
            }
        }
        else {
            messageLabelTextField.text = "7"
            //TODO add showing alert "Register first"
        }
        self.view.endEditing(true)
    }
    @IBAction func openHelpMessage(_ sender: UIButton) {
        self.helpView.isHidden = !self.helpView.isHidden
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Two functions for moving the screens content up so the keyboard doesn't mask the content and down
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

}
