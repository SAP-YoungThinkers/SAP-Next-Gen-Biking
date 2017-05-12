//
//  ViewController.swift
//  Getmed
//
//  Created by Gor Avakian on 26/12/2016.
//  Copyright © 2016 Gor Avakian. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pop() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func close() {
        if self.navigationController != nil {
            self.pop()
        }
        else {
            self.dismiss()
        }
    }
    
    @IBAction func hideKeyboard() {
        self.view.endEditing(true)
    }
}

extension UITabBarController {
    
    override func close() {
        self.viewControllers?.forEach { (c) in
            if let nav = c as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
            c.presentedViewController?.dismiss()
        }
    }
}
