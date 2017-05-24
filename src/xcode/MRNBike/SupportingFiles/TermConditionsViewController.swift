//
//  TermConditionsViewController.swift
//  MRNBike
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class TermConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeTerm(_ sender: Any) {
      self.close()  
    }


    @IBAction func AgreeButton(_ sender: Any) {
    self.close()
    }


}
