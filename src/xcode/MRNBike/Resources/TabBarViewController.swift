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


        
        // Do any additional setup after loading the view.
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTabBarSeparators()
        AddBackgroundColor()
    }
    
    
    // Adding Separatos between TabBarItems
    
    func setupTabBarSeparators() {
        let itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))
        let separatorWidth: CGFloat = 0.5
        
        for i in 0...(tabBar.items!.count - 1) {
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height))

            separator.backgroundColor = UIColor.black
            
            self.tabBar.addSubview(separator)
        }
    }
    
    
    //Adding Background Colour for selected and unselected TabBarItems
    
    func AddBackgroundColor(){
       
        
        // Sets the default color of the icon of the selected UITabBarItem and Title
        tabBar.tintColor = UIColor(red: 29.0/255.0, green: 41.0/255.0, blue: 52.0/255.0, alpha: 1.0)
        tabBar.barTintColor = UIColor(red: 29.0/255, green: 41.0/255.0, blue: 52.0/255.0, alpha: 1.0)
        
        tabBar.selectionIndicatorImage = UIImage().makeImageWithColorAndSize(color: .white, size: CGSize(width: tabBar.frame.width/5, height: tabBar.frame.height))
        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        
        for item in tabBar.items! {
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

