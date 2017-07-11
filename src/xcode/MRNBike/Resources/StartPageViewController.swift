import UIKit

class StartPageViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var takeTourButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set text
        startButton.setTitle(NSLocalizedString("start", comment: ""), for: .normal)
        takeTourButton.setTitle(NSLocalizedString("takeTour", comment: ""), for: .normal)
        
        self.navigationController?.isNavigationBarHidden = true
        
        var userShouldLogin = true
        if UserDefaults.standard.object(forKey: StorageKeys.shouldLoginKey) != nil {
            userShouldLogin = UserDefaults.standard.object(forKey: StorageKeys.shouldLoginKey) as! Bool
        }
        
        if userShouldLogin {
            // user doesnt exist
            print("user does not exist, redirecting to register")
            let controller = TourViewController()
            controller.startRidingAction = {
                self.performSegue(withIdentifier: "segSignIn", sender: self)
            }
        } else {            
            // user exists
            print("user exists, redirecting to dashboard")
            
            // Quick and dirty solution because of the lack of time. Please refactor this
            if let tmpMail = KeychainService.loadEmail() as String? {
                User.getUser(mail: tmpMail)
            }
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(controller, animated: true, completion: nil)
        }
    }
}
