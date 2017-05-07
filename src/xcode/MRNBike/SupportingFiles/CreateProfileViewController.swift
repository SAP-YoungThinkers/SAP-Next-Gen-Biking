//
//  CreateProfileViewController.swift
//  MRNBike
//
//  Created by 1 on 06.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var photoImageView: UIImageView!


    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var firstnameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var infoShareSwitch: UISwitch!
    
    @IBOutlet weak var userWeightSlider: UISlider!
 
    
    @IBOutlet weak var userWheelSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {

        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }

    @IBAction func saveProfileButton(sender: AnyObject) {
        let user = User()
       
        // Check passwords
        if(passwordTextField.text == repeatPasswordTextField.text){
            user.accountPassword = passwordTextField.text
        } else {
            user.accountPassword = nil
        }
        
        user.accountSurname = surnameTextField.text
        user.accountFirstName = firstnameTextField.text
        user.accountName = emailTextField.text
        user.accountShareInfo = infoShareSwitch.isOn
        user.accountUserWeight = userWeightSlider.value
        user.accountUserWheelSize = userWheelSlider.value
        
        // Creation object
        var users = UserDefaults.standard.object(forKey: "userTable") as? Dictionary<String,User>
        if (users == nil) {
            // Creation hash table
            users = Dictionary<String,User>.init()
            // Adding table to the stored data
            UserDefaults.standard.set(users, forKey: "userTable")
            // Sent data to the table
            users![user.accountName] = user
           }
        else {
            users![user.accountName] = user
         
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
