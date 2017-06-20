//
//  HomeViewController.swift
//  MRNBike
//
//  Created by Ziad Abdelkader on 5/20/17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var wheelRotationLabel: UILabel!
    @IBOutlet weak var burgerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var treesSavedLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Method to be called each time the screen appears to update the UI.
    private func updateUI() {
        
        // Setting The Username to the Label in Home Screen.
        
        if let firstName = UserDefaults.standard.string(forKey: "userFirstName") {
            userNameLabel.text = firstName
        }
        if let lastName = UserDefaults.standard.string(forKey: "userSurname"), let label = userNameLabel.text {
            userNameLabel.text = "\(label) \(lastName)"
        }
        
        //Updating the Picture in Homescreen.
        
        let imageData = UserDefaults.standard.value(forKey: "userProfileImage")
        if let image = imageData as? Data {
            userImage.image = UIImage(data: image)
        }
        
        //Updating the labels after each tracking.
        wheelRotationLabel.text = String(UserDefaults.standard.integer(forKey: "wheelRotation"))
        burgerLabel.text = String(UserDefaults.standard.double(forKey: "burgers"))
        distanceLabel.text = String(UserDefaults.standard.double(forKey: "distance"))
        treesSavedLabel.text = String(UserDefaults.standard.double(forKey: "treesSaved"))
    }
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
