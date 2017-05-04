//
//  StartViewController.swift
//  MRNBike
//
//  Created by 1 on 03.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
   
    @IBOutlet weak var opentour: UIButton!
    
    @IBOutlet weak var openBackImageView: UIImageView!
    
    @IBOutlet weak var startRidingButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func openTour(_ sender: UIButton) {
        openBackImageView.isHidden = false
        startRidingButton.isHidden = false
        closeButton.isHidden = false
    }
    
    @IBAction func closeTour(_ sender: UIButton!)
    {
        openBackImageView.isHidden = true
        startRidingButton.isHidden = true
        closeButton.isHidden = true
    }
 
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
