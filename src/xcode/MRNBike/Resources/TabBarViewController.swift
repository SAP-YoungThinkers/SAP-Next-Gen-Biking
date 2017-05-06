//
//  TabBarViewController.swift
//  MRNBike
//
//  Created by Ziad Abdelkader on 5/6/17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBarSeparators()
        AddBackgroundColor()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    // Adding Separatos between TabBarItems
    
    func setupTabBarSeparators() {
        let itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))
        
       
        let separatorWidth: CGFloat = 0.5
        
        for i in 0...(self.tabBar.items!.count - 1) {
            
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height))

            separator.backgroundColor = UIColor.black
            
            self.tabBar.addSubview(separator)
        }
    }
    
    
    //Adding Background Colour for selected and unselected TabBarItems
    
    func AddBackgroundColor(){
       
        UITabBar.appearance().barTintColor = UIColor.init(red: 29.0/255, green: 41.0/255, blue: 52.0/255, alpha: 1.0)
        
        //UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(color: UIColor.white, size: CGSize(tabBar.frame.width/5, tabBar.frame.height))
        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        for item in self.tabBar.items! {
            if let image = item.image {
                item.image = image.withRenderingMode(.alwaysOriginal)
            }
        }
        }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}

