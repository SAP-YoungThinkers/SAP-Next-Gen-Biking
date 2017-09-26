import UIKit

class StartPageViewController: UIViewController, PushViewControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var takeTourButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tourModal" {
            let controller = segue.destination as! TourViewController
            controller.delegate = self
        }
    }
    
    func dismissViewController(_ controller: UIViewController) {
        print("function wurde aufgerufen")
        controller.dismiss(animated: true) { () -> Void in
            // push to login
            self.performSegue(withIdentifier: "fromStartToLogin", sender: nil)
            print("\n\n\n\n\nyes it worked!!!!!\n\n\n\n\n")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set text
        startButton.setTitle(NSLocalizedString("start", comment: ""), for: .normal)
        takeTourButton.setTitle(NSLocalizedString("takeTour", comment: ""), for: .normal)
        
        self.navigationController?.isNavigationBarHidden = true
        
        var rememberMe: String
        
        
        if KeychainService.loadRemember() == nil {
            //User not registered
            rememberMe = "no"
        } else {
            rememberMe = KeychainService.loadRemember()! as String
        }
        
        if rememberMe == "no" {
            let controller = TourViewController()
        } else {
            // user exists
            if let userMail = KeychainService.loadEmail() as String? {
                
                //Show activity indicator
                let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
                present(activityAlert, animated: false, completion: nil)
                
                if !(Reachability.isConnectedToNetwork()) {
                    
                    // no Internet connection
                    
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false) {
                        self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
                    }
                    
                    
                } else {
                    
                    // bad Internet
                    
                    ClientService.getUser(mail: userMail, completion: { (data, error) in
                        if error == nil {
                            
                            guard let responseData = data else {
                                //Dismiss activity indicator
                                activityAlert.dismiss(animated: false, completion: nil)
                                //An error occured
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                                return
                            }
                            
                            User.createSingletonUser(userData: responseData)
                            
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            
                            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
                            self.present(controller, animated: true, completion: nil)
                        } else {
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            
                            //An error occured
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        }
                    })
                    
                }
                
            }
        }
    }
}
