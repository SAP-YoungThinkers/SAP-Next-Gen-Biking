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
    
    let firstVC = FirstViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        uploadButton.layer.cornerRadius = 10
        uploadButton.layer.borderWidth = 2
        uploadButton.layer.borderColor = UIColor(red:0.94, green:0.67, blue:0.0, alpha:1.0).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
//    @IBAction func intervalSlider(_ sender: Any) {
//        let step: Float = 1
//        let roundedValue = round(intervalSliderOutlet.value / step) * step
//        intervalSliderOutlet.value = roundedValue
//        
//        intervalValueOutlet.text = "\(Int(roundedValue))" + " Sekunden"
//        
//        firstVC.setTimerValue(timeInt: Int(roundedValue))
//    }
    
    @IBAction func uploadBtnEvent(_ sender: UIButton) {
        
        if let loadedData = UploadHelper.loadGPS() {
            let alertController = UIAlertController(title: "Next Gen Biking", message:
                "Erfolgreich \(loadedData.count) Wegpunkte hochgeladen.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Weiter geht's", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Next Gen Biking", message:
                "Keine Punkte zum Hochladen gefunden", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Weiter geht's", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }

}

