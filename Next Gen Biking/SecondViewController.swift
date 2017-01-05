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
    
    
    let uploadString = NSLocalizedString("Upload data", comment: "uploadButton")
    let alertString = NSLocalizedString("Number of uploaded trackpoints: ", comment: "Upload success")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.layer.cornerRadius = 10
        uploadButton.layer.borderWidth = 2
        uploadButton.layer.borderColor = config.yellowColor.cgColor
        
        uploadButton.setTitle(uploadString, for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @IBAction func uploadBtnEvent(_ sender: UIButton) {
        
        if let loadedData = StorageHelper.loadGPS() {
            
            let jsonObj = StorageHelper.generateJSON(points: loadedData)
            
            StorageHelper.uploadToHana(scriptName: "bringItToHana.xsjs", paramDict: nil, jsonData: jsonObj)
            
            presentAlert(numberOfPoints: loadedData.count)
            
        } else {
            presentAlert(numberOfPoints: 0)
        }
        
    }
    
    func presentAlert(numberOfPoints: Int) {
        
        let alertController = UIAlertController(title: "Next-Gen Biking", message: alertString.appending(String(numberOfPoints)), preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    
    }

}

