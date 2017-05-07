//
//  EditProfileViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 03.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import Foundation
import UIKit

class EditProfileViewController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageBG: UIImageView!
    @IBOutlet weak var PrefStack: UIStackView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var userBar: UIView!
    @IBOutlet weak var scrollView : UIScrollView!
    
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
    
    @IBAction func weightChanged(_ sender: UISlider) {
        inputIndicatorWeight.text = "\(Int(inputWeight.value)) kg"
        inputIndicatorWeight.sizeToFit()
    }
    
    @IBAction func wheelChanged(_ sender: UISlider) {
        inputIndicatorWheel.text = "\(Int(inputWheelSize.value)) Inch"
        inputIndicatorWheel.sizeToFit()
    }
    
    
    var userBarViewController : UserBarViewController!
    let userBarSegueName = "userBarSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // surname input
        if let lastNameView = userBarViewController?.view.viewWithTag(4) as? UITextField {
            lastNameView.font = UIFont.init(name: "Montserrat-Light", size: 22)!
        }
        
        // first name input
        if let firstNameView = userBarViewController?.view.viewWithTag(5) as? UITextField {
            firstNameView.font = UIFont.init(name: "Montserrat-Light", size: 22)!
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
        
        // slider targets
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == userBarSegueName {
            userBarViewController = segue.destination as? UserBarViewController
        }
    }
    
}


class UserBarViewController: UIViewController {
    // has to stick here...
    // ...because i need the class in EditProfileViewController!
}
