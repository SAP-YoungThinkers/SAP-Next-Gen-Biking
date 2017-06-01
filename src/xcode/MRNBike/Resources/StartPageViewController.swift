

import UIKit

class StartPageViewController: UIViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        var userShouldLogin = true
        if UserDefaults.standard.object(forKey: StorageKeys.shouldLoginKey) != nil {
            userShouldLogin = UserDefaults.standard.object(forKey: StorageKeys.shouldLoginKey) as! Bool
        }
        
        if(!userShouldLogin) {
            // user exists
            print("user exists, redirecting to dashboard")
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(controller, animated: true, completion: nil)
        }
        else {
            // user doesnt exist
            print("user does not exist, redirecting to register")
            let controller = TourViewController()
            controller.startRidingAction = {
                self.performSegue(withIdentifier: "segSignIn", sender: self)
            }
        }

    }

}
