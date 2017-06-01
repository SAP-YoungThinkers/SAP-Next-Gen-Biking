//
//  StartViewController.swift
//  MRNBike
//
//  Created by 1 on 03.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class StartPageViewController: UIViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        // read values from local space
        let userData = UserDefaults.standard
        let tmpUserMail = userData.object(forKey: "userMail")
        let tmpUserPwd = userData.object(forKey: "userPassword")
        
        if(tmpUserMail != nil && tmpUserPwd != nil) {
            // user exists
            print("user exists, redirecting to dashboard")
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(controller, animated: true, completion: nil)
        }
        else {
            // user doesnt exist
            print("user does not exist, redirecting to register")
            let controller = TourViewController()
            controller.startRidingAction = {
                self.performSegue(withIdentifier: "segSignIn", sender: self)
            }
        }

    }

}
