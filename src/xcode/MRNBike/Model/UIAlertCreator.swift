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

    class func waitAlert(message: String) -> UIAlertController {
        
        let waitAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        waitAlert.view.addSubview(loadingIndicator)
        
        return waitAlert
    }
    
}
