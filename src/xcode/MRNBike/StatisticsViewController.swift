//
//  StatisticsViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 28.08.17.
//
//

import UIKit

class StatisticsViewController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var distanceTab: UITabBarItem!
    @IBOutlet weak var caloriesTab: UITabBarItem!
    @IBOutlet weak var totalWheels: UILabel!
    @IBOutlet weak var totalWheelsLabel: UILabel!
    
    var tempPlaceholder : UIView?
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    private var shadowImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Titles
        self.navigationItem.title = NSLocalizedString("statisticsTitle", comment: "")
        distanceTab.title = NSLocalizedString("distanceTitle", comment: "")
        caloriesTab.title = NSLocalizedString("caloriesTitle", comment: "")
        totalWheelsLabel.text = NSLocalizedString("totalWheelsTitle", comment: "")
        
        // Design
        tabBar.delegate = self
        tabBar.selectedItem = distanceTab
        tabBar.shadowImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 3.0)
        tempPlaceholder = setupTabBarSeparators()
        
        // Set Font, Size for Items
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 60
        self.tabBar.frame = tabFrame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(tabBar.selectedItem == distanceTab) {
            distancePressed()
        } else if (tabBar.selectedItem == caloriesTab){
            caloriesPressed()
        }
        
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shadowImageView?.isHidden = false
    }
    
    func distancePressed() {
        
    }
    
    func caloriesPressed() {
        
    }
    
    func setupTabBarSeparators() -> UIView {
        let itemWidth = floor(self.tabBar.frame.width / CGFloat(self.tabBar.items!.count))
        let separatorWidth: CGFloat = 0.5
        let separator = UIView(frame: CGRect(x: itemWidth + 0.5 - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.height))
        separator.backgroundColor = UIColor(red: (170/255.0), green: (170/255.0), blue: (170/255.0), alpha: 1.0)
        self.tabBar.insertSubview(separator, at: 1)
        
        return separator
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }

}
