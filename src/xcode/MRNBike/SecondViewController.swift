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
        uploadButton.setTitle(NSLocalizedString("upload_button_text", comment: "Upload button title"), for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @IBAction func uploadBtnEvent(_ sender: UIButton) {
        
        //TODO: Better feedback. At the moment it just counts the routes in the local storage (even the empty ones)
        
        firstVC.saveCollectedDataLocally()
        
        if let loadedData = StorageHelper.loadGPS() {
            
            let jsonObj = StorageHelper.generateJSON(tracks: loadedData)
            
            StorageHelper.uploadToHana(scriptName: "importData/bringItToHana.xsjs", paramDict: nil, jsonData: jsonObj)
            
            presentAlert(numberOfPoints: loadedData.count)
            
        } else {
            presentAlert(numberOfPoints: 0)
        }
        
    }
    
    func presentAlert(numberOfPoints: Int) {
        let infoString = NSLocalizedString("upload_Info", comment: "Info after uploading data")
        let info = "\(infoString) \(numberOfPoints)"
        let alertController = UIAlertController(title: "Next-Gen Biking", message: info, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    
    }

}

