//
//  SecondViewController.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 22.11.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var intervalSliderOutlet: UISlider!
    
    @IBOutlet weak var intervalValueOutlet: UILabel!

    
    let firstVC = FirstViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        uploadButton.layer.cornerRadius = 10
        uploadButton.layer.borderWidth = 2
        uploadButton.layer.borderColor = UIColor(red:0.94, green:0.67, blue:0.0, alpha:1.0).cgColor
        intervalSliderOutlet.value = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func intervalSlider(_ sender: Any) {
        let step: Float = 1
        let roundedValue = round(intervalSliderOutlet.value / step) * step
        intervalSliderOutlet.value = roundedValue
        
        intervalValueOutlet.text = "\(Int(roundedValue))" + " Sekunden"
        
        firstVC.setTimerValue(timeInt: Int(roundedValue))
    }
    
    @IBAction func uploadBtnEvent(_ sender: UIButton) {
        
        firstVC.loadGPS()
        
    }


}

