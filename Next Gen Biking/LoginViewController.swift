//
//  LoginViewController.swift
//  Next Gen Biking
//
//  Created by Bormeth, Marc on 09/01/2017.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPWTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    let config = Configurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameTF.delegate = self
        self.userPWTF.delegate = self

        loginBtn.layer.cornerRadius = 10
        loginBtn.layer.borderWidth = 2
        loginBtn.layer.borderColor = config.yellowColor.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Action
    @IBAction func onPressLogin() {
        
        User.accountName = userNameTF.text
        User.accountPassword = userPWTF.text
        
        userNameTF.text = nil
        userPWTF.text = nil
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
