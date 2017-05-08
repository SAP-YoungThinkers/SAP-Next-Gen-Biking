//
//  CreateProfileViewController.swift
//  MRNBike
//
//  Created by 1 on 06.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBOutlet weak var photoImageView: UIImageView!
   
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var firstnameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var infoShareSwitch: UISwitch!
    
    @IBOutlet weak var userWeightSlider: UISlider!
 
    
    @IBOutlet weak var userWheelSlider: UISlider!
    
    @IBOutlet weak var printLabel: UILabel!
    
    
   // Slider value changes
    @IBOutlet weak var currentWeightLabel: UILabel!
    
    @IBAction func weightSliderValueChange(_ sender: UISlider) {
    var currentWeight = Int (sender.value)
        currentWeightLabel.text = "\(currentWeight) " + " kg"
    }
    
    @IBOutlet weak var currentWheelLabel: UILabel!

    @IBAction func currentWheelChange(_ sender: UISlider) {
    var currentWheel = Int (sender.value)
    currentWheelLabel.text = "\(currentWheel)" + " inch"
        
    }
// Picture
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker. 
        dismiss(animated: true, completion: nil) 
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil) 
    }
    
// Save profile

    @IBAction func saveOnPressed(_ sender: UIButton) {
        
        let user = User()
       
        // Check passwords
        if(passwordTextField.text == repeatPasswordTextField.text){
            user.accountPassword = passwordTextField.text
        } else {
            //user.accountPassword = nil
            // TODO show alert
            printLabel.text = ("different passwords")
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
            printLabel.text = ("User Seved to new user Table")
           }
        else {
            users![user.accountName] = user
            printLabel.text = ("user saved to existing user table")
         
        }
        UserDefaults.standard.synchronize()
        self.view.endEditing(true)
        self.close()
    }
}
