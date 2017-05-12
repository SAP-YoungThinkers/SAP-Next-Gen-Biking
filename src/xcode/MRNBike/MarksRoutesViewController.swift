//
//  MarksRoutesViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 26.04.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//
import UIKit
import CoreGraphics

class MarksRoutesViewController: UIViewController {
    
    @IBOutlet weak var topBar: UITabBar!
    @IBOutlet weak var routeInformation: UITabBarItem!
    @IBOutlet weak var myRoutes: UITabBarItem!
    
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display line on selected
        topBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: topBar.frame.width/CGFloat(topBar.items!.count), height: topBar.frame.height), lineWidth: 3.0)
        
        // Remove Grey Lines by initialising empty Image
        topBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // Set Font, Size for Items
        for item in topBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
            item.titlePositionAdjustment = UIOffset.init(horizontal: 0, vertical: -17)
        }
        
        // add seperator
        setupTabBarSeparators()
        
    }
    
    
    func setupTabBarSeparators() {
        let itemWidth = floor(self.topBar.frame.size.width / CGFloat(self.topBar.items!.count))
        
        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5
        
        // iterate through the items in the Tab Bar, except the last one
        for i in 0...(self.topBar.items!.count - 1) {
            
            // make a new separator at the end of each tab bar item
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i) + 0.5 - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.topBar.frame.size.height))
            
            // set the color to light gray (default line color for tab bar)
            separator.backgroundColor = UIColor(red: (170/255.0), green: (170/255.0), blue: (170/255.0), alpha: 1.0)
            
            self.topBar.addSubview(separator)
        }
    }
    
}

extension UIImage {
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint(x: 0,y :size.height - lineWidth), size: CGSize(width: size.width, height: lineWidth)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
