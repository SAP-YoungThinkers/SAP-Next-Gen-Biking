//
//  DashboardController.swift
//  MRNBike
//
//  Created by Bartosz Wilkusz on 19.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit


class DashboardController: UIViewController {
    
    @IBOutlet weak var wheelRotationLabel: UILabel!
    @IBOutlet weak var burgerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var treesSavedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wheelRotationLabel.text = String(UserDefaults.standard.integer(forKey: "wheelRotation"))
        burgerLabel.text = String(UserDefaults.standard.double(forKey: "burgers"))
        distanceLabel.text = String(UserDefaults.standard.double(forKey: "distance"))
        treesSavedLabel.text = String(UserDefaults.standard.double(forKey: "treesSaved"))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Action
    
  
    
    // MARK: - Helper Functions
    
    
    
}

