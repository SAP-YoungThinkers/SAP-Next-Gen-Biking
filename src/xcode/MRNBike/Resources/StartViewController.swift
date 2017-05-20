//
//  StartViewController.swift
//  MRNBike
//
//  Created by 1 on 03.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        // ------------------------------------------------------
        // TODO: backend check the current login state!
        // ------------------------------------------------------
        
        
        let refreshAlert = UIAlertController(title: "login last time", message: "Assume: Were you already registered, and is the login still valid?", preferredStyle: UIAlertControllerStyle.alert)
        
        // if login is TRUE -> DASHBOARD
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(controller, animated: true, completion: nil)
        }))
        
        // if login is FALSE -> SIGN IN PAGE
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            let controller = TourViewController()
            controller.startRidingAction = {
                self.performSegue(withIdentifier: "segSignIn", sender: self)
            }
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }

}
