

import UIKit


extension UIViewController {
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeViewController() {
        if self.navigationController != nil {
            self.dismissViewController()
        }
        else {
            self.popViewController()
        }
    }
}



extension UITabBarController {
    
    override func closeViewController() {
        self.viewControllers?.forEach { (c) in
            if let nav = c as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
            c.presentedViewController?.dismissViewController()
        }
    }
}
