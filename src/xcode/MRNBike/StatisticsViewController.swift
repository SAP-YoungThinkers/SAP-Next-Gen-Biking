//
//  StatisticsViewController.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 28.08.17.
//
//

import UIKit
import PagingMenuController

class StatisticsViewController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var distanceTab: UITabBarItem!
    @IBOutlet weak var caloriesTab: UITabBarItem!
    @IBOutlet weak var totalWheels: UILabel!
    @IBOutlet weak var totalWheelsLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private var tempPlaceholder : UIView?
    private let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    private var shadowImageView: UIImageView?
    
    
    // Menu handling from outside view
    @IBAction func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.move(toPage: (pagingMenuController.currentPage+1), animated: true)
    }
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.move(toPage: (pagingMenuController.currentPage-1), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*  ------------------------ *\
         *      LANGUAGE & TEXT
        \*  ------------------------ */
        self.navigationItem.title = NSLocalizedString("statisticsTitle", comment: "")
        distanceTab.title = NSLocalizedString("distanceTitle", comment: "")
        caloriesTab.title = NSLocalizedString("caloriesTitle", comment: "")
        totalWheelsLabel.text = NSLocalizedString("totalWheelsTitle", comment: "")
        let user = User.getUser()
        totalWheels.text = String(user.wheelRotation!)
        
        /*  ------------------------ *\
         *      DESIGN
        \*  ------------------------ */
        tabBar.delegate = self
        tabBar.selectedItem = distanceTab
        tabBar.shadowImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 3.0)
        tempPlaceholder = setupTabBarSeparators()
        self.childViewControllers.first!.view.backgroundColor = UIColor.clear
        
        // Set Font, Size for Items
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
        }
        
        /*  ------------------------ *\
         *      SWIPE MENU
        \*  ------------------------ */
        struct menuPrev: MenuItemViewCustomizable {}
        struct menuActual: MenuItemViewCustomizable {}
        struct menuNext: MenuItemViewCustomizable {}
        
        struct MenuOptions: MenuViewCustomizable {
            var itemWidth : CGFloat
            var height : CGFloat
            var itemsOptions: [MenuItemViewCustomizable] {
                return [menuPrev(), menuActual(), menuNext()]
            }
            var focusMode : MenuFocusMode {
                return .none
            }
            var displayMode : MenuDisplayMode {
                return .standard(widthMode: MenuItemWidthMode.fixed(width: itemWidth), centerItem: true, scrollingMode: MenuScrollingMode.pagingEnabled)
            }
            var backgroundColor: UIColor = UIColor.clear
            var selectedBackgroundColor: UIColor = UIColor.clear
            init(_ width : CGFloat, height: CGFloat) {
                self.itemWidth = width
                self.height = height
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            var width : CGFloat
            var height : CGFloat
            var componentType: ComponentType {
                return .menuView(menuOptions: MenuOptions(width, height: height))
            }
            var backgroundColor: UIColor = UIColor.clear
            var defaultPage: Int = 1 // Mitte!
            init(_ width: CGFloat, height: CGFloat) {
                self.width = width
                self.height = height
            }
        }
    
        let options = PagingMenuOptions(view.bounds.width * 0.33, height: CGFloat(67.0))
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)
        
        
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
