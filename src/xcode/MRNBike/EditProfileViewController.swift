//
//  EditProfileViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 03.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

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
    
    // save button pressed
    @IBAction func saveRequest(_ sender: UIBarButtonItem) {
        
        let userData = UserDefaults.standard
        
        // password: there will be inserted a random string
        // and when it wasn't changed, password won't be overwritten/saved
        
        let passwordAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        
        if (inputPassword.text == inputPasswordRepeat.text) {
            
            if (inputPassword.text != tmpPasswordHash) {
            
                if (inputPassword.text != "") {
                    // was changed, so save!
                    userData.set(inputPassword.text, forKey: "userPassword")
                }
                else {
                    // password empty
                    passwordAlert.title = "Password empty"
                    passwordAlert.message = "Okay, you did not fill in any password. So we won't overwrite it!"
                    passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                    self.present(passwordAlert, animated: true, completion: nil)
                    print("password empty")
                    return
                }
            }
            else {
                // password not changed
                passwordAlert.title = "Password not changed"
                passwordAlert.message = "Okay, you did not change the password. So we won't overwrite it!"
                passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                self.present(passwordAlert, animated: true, completion: nil)
                print("password wont be overwritten")
            }
        }
        else {
            // passwords dont match
            passwordAlert.title = "Password Mismatch"
            passwordAlert.message = "Please repeat the same password!"
            passwordAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(passwordAlert, animated: true, completion: nil)
            print("passwords dont match")
            return
        }
        
        // SAVE OTHERS
        
        if let inputSurnameView = userBarViewController?.view.viewWithTag(4) as? UITextField {
            userData.set(inputSurnameView.text, forKey: "userSurname")
        }
        if let firstNameView = userBarViewController?.view.viewWithTag(5) as? UITextField {
            userData.set(firstNameView.text, forKey: "userFirstName")
        }
        userData.set(inputEmail.text, forKey: "userMail")
        userData.set(inputActivity.isOn, forKey: "userShareActivity")
        userData.set(Int(inputWeight.value), forKey: "userWeight")
        userData.set(Int(inputWheelSize.value), forKey: "userWheelSize")
        
        // save image
        let imageData = UIImageJPEGRepresentation(imageBG.image!, 1.0)
        userData.set(imageData, forKey: "userProfileImage")
        
        self.navigationController?.popViewController(animated: true)
        
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
    
    var userBarViewController : UserBarViewController!
    let userBarSegueName = "userBarSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // read values from local space
        let userData = UserDefaults.standard
        
        // surname input
        if let inputSurnameView = userBarViewController?.view.viewWithTag(4) as? UITextField {
            inputSurnameView.font = UIFont.init(name: "Montserrat-Light", size: 22)!
            if let tmpUserSurname = userData.object(forKey: "userSurname") {
                inputSurnameView.text = tmpUserSurname as? String
            }
        }
        // first name input
        if let firstNameView = userBarViewController?.view.viewWithTag(5) as? UITextField {
            firstNameView.font = UIFont.init(name: "Montserrat-Light", size: 22)!
            if let tmpUserFirstName = userData.object(forKey: "userFirstName") {
                firstNameView.text = tmpUserFirstName as? String
            }
        }
        if let tmpUserMail = userData.object(forKey: "userMail") {
            inputEmail.text = tmpUserMail as? String
        }
        if let tmpUserShareActivity = userData.object(forKey: "userShareActivity") {
            inputActivity.isOn = tmpUserShareActivity as! Bool
        }
        if let tmpUserWeight = userData.object(forKey: "userWeight") {
            inputWeight.value = Float(tmpUserWeight as! Int)
            inputIndicatorWeight.text = "\(Int(inputWeight.value)) kg"
            inputIndicatorWeight.sizeToFit()
        }
        if let tmpUserWheelSize = userData.object(forKey: "userWheelSize") {
            inputWheelSize.value = Float(tmpUserWheelSize as! Int)
            inputIndicatorWheel.text = "\(Int(inputWheelSize.value)) Inches"
            inputIndicatorWheel.sizeToFit()
        }
        if let tmpUserPhoto = userData.object(forKey: "userProfileImage") {
            let myImage = UIImage(data: tmpUserPhoto as! Data)
            imageBG.image = myImage
            if let profileView : UIImageView = userBarViewController?.view.viewWithTag(1) as? UIImageView {
                profileView.image = myImage
            }
        }
        
        // password: there will be inserted a random string
        // and when it wasn't changed, password won't be overwritten/saved
        tmpPasswordHash = randomString(5)
        inputPassword.text = tmpPasswordHash
        inputPasswordRepeat.text = tmpPasswordHash
        
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
    
    
}

class UserBarViewController: UIViewController {
    // has to stick here...
    // ...because i need the class in EditProfileViewController!
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
