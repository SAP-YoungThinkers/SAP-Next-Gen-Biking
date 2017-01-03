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
    let config = Configurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.layer.cornerRadius = 10
        uploadButton.layer.borderWidth = 2
        uploadButton.layer.borderColor = config.yellowColor.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @IBAction func uploadBtnEvent(_ sender: UIButton) {
        
        if let loadedData = StorageHelper.loadGPS() {
            
            let jsonObj = StorageHelper.generateJSON(points: loadedData)
            
            StorageHelper.uploadToHana(scriptName: "bringItToHana.xsjs", paramDict: nil, jsonData: jsonObj)
            
            let alertController = UIAlertController(title: "Next-Gen Biking", message:
                "Erfolgreich \(loadedData.count) Wegpunkte hochgeladen.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Weiter geht's", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Next-Gen Biking", message:
                "Keine Punkte zum Hochladen gefunden", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Weiter geht's", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }

}

