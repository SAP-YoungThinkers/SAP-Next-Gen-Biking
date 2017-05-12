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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TourViewController {
            controller.startRidingAction = {
                self.performSegue(withIdentifier: "segSignIn", sender: self)
            }
   
    }

}
}
