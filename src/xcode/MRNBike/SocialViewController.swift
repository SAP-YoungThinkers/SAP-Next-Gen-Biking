import UIKit

class SocialViewController: UIViewController, UITabBarDelegate {
    
    //MARK: Properties
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var friendsBarItem: UITabBarItem!
    @IBOutlet weak var groupsBarItem: UITabBarItem!
    @IBOutlet weak var friendsContainer: UIView!
    @IBOutlet weak var groupsContainer: UIView!
    
    var tempPlaceholder : UIView?
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        self.navigationItem.title = NSLocalizedString("socialFriendsTitle", comment: "")
        friendsBarItem.title = NSLocalizedString("frindsTabBarItem", comment: "")
        groupsBarItem.title = NSLocalizedString("groupsTabBarItem", comment: "")
        
        tabBar.delegate = self
        tabBar.selectedItem = friendsBarItem
        
        // Remove Grey Lines by initialising empty Image
        tabBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // Set Font, Size for Items
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
            item.titlePositionAdjustment = UIOffset.init(horizontal: 0, vertical: -17)
        }
        
        // fix size errors
        tabBar.bounds.size.width = UIScreen.main.bounds.width
        tabBar.itemWidth = CGFloat(tabBar.bounds.size.width/CGFloat(tabBar.items!.count))
        tabBar.updateConstraints()
        
        // display line on selected
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 3.0)
        
        // add seperator
        tempPlaceholder = setupTabBarSeparators()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if(tabBar.selectedItem == friendsBarItem) {
            loadFriendsContent()
        } else {
            loadGroupsContent()
        }
    }
    
    //This method will be called when user changes tab.
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(tabBar.selectedItem == friendsBarItem) {
            loadFriendsContent()
        } else {
            loadGroupsContent()
        }
    }
    
    func loadFriendsContent() {
        groupsContainer.isHidden = true
        friendsContainer.isHidden = false
    }
    
    func loadGroupsContent() {
        friendsContainer.isHidden = true
        groupsContainer.isHidden = false
    }
    
    func updateTapBar() {
        // remove seperators and images
        self.tempPlaceholder?.removeFromSuperview()
        tabBar.selectionIndicatorImage = UIImage()
        
        // add again
        self.tempPlaceholder? = setupTabBarSeparators()
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 3.0)
    }

    func setupTabBarSeparators() -> UIView {
        let itemWidth = floor(self.tabBar.frame.width / CGFloat(self.tabBar.items!.count))
        
        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5
        
        // make a new separator at the end of each tab bar item
        let separator = UIView(frame: CGRect(x: itemWidth + 0.5 - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.height))
        
        // set the color to light gray (default line color for tab bar)
        separator.backgroundColor = UIColor(red: (170/255.0), green: (170/255.0), blue: (170/255.0), alpha: 1.0)
        
        self.tabBar.insertSubview(separator, at: 1)
        
        return separator
    }
}
