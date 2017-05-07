//
//  FirstLogInViewController.swift
//  MRNBike
//
//  Created by 1 on 04.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class FirstLogInViewController: UIViewController {
  
    @IBOutlet private var helpView: UIView!

    //AMRK: - Handlers
    
    @IBAction func openHelpMessage(_ sender: UIButton) {
        self.helpView.isHidden = !self.helpView.isHidden
    }
}
