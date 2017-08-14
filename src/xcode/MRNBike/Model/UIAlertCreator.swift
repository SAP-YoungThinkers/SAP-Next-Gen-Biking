//
//  UIAlertCreator.swift
//  MRNBike
//
//  Created by Bartosz Wilkusz on 08.07.17.
//
//

import Foundation
import UIKit

public class UIAlertCreator: NSObject {

    //Alert for activity indicator
    static func waitAlert(message: String) -> UIAlertController {
        
        let waitAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        waitAlert.view.addSubview(loadingIndicator)
        
        return waitAlert
    }
    
    //With standard action
    static func infoAlert(title: String, message: String) -> UIAlertController {
        
        let infoAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: nil)
 
        infoAlert.addAction(defaultAction)
        infoAlert.view.tintColor = UIColor(red: 255/255, green: 87/255, blue: 34/255, alpha: 1)
        infoAlert.view.layer.cornerRadius = 25
        
        return infoAlert
    }
    
    //With custom action
    static func infoAlertNoAction(title: String, message: String) -> UIAlertController {
        
        let infoAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        infoAlert.view.tintColor = UIColor(red: 255/255, green: 87/255, blue: 34/255, alpha: 1)
        infoAlert.view.layer.cornerRadius = 25
        
        return infoAlert
    }

    
}
