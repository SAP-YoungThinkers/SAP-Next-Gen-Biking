import UIKit

class SocialViewController: UIViewController, UITabBarDelegate {
    
    //MARK: Properties
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var friendsBarItem: UITabBarItem!
    @IBOutlet weak var groupsBarItem: UITabBarItem!
    @IBOutlet weak var friendsContainer: UIView!
    @IBOutlet weak var groupsContainer: UIView!
    
    var tempPlaceholder : UIView?
    private var shadowImageView: UIImageView?
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        //Set text
        self.navigationItem.title = NSLocalizedString("socialFriendsTitle", comment: "")
        friendsBarItem.title = NSLocalizedString("frindsTabBarItem", comment: "")
        groupsBarItem.title = NSLocalizedString("groupsTabBarItem", comment: "")
        

        /*  ------------------------ *\
         *      DESIGN
        \*  ------------------------ */
        tabBar.delegate = self
        tabBar.selectedItem = friendsBarItem
        tabBar.shadowImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: primaryColor, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: 60), lineWidth: 3.0)
        tempPlaceholder = setupTabBarSeparators()
        self.childViewControllers.first!.view.backgroundColor = UIColor.clear
        
        // Set Font, Size for Items
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.init(name: "Montserrat-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if(tabBar.selectedItem == friendsBarItem) {
            loadFriendsContent()
        } else {
            loadGroupsContent()
        }
        
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueShowGroup"){
        let showGroupViewController = segue.destination as! ShowGroupViewController
        let groupListViewController = sender as! GroupListViewController
        showGroupViewController.group = groupListViewController.groups[groupListViewController.tempRowId]
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
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 60
        self.tabBar.frame = tabFrame
        self.tabBar.updateConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shadowImageView?.isHidden = false
    }
    
    func setupTabBarSeparators() -> UIView {
        let itemWidth = floor(self.tabBar.frame.width / CGFloat(self.tabBar.items!.count))
        let separatorWidth: CGFloat = 0.5
        let separator = UIView(frame: CGRect(x: itemWidth + 0.5 - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: 60))
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
