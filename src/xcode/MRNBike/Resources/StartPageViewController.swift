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
        
        var rememberMe: String
        
        
        if KeychainService.loadRemember() == nil {
            //User not registered
            rememberMe = "no"
        } else {
            rememberMe = KeychainService.loadRemember()! as String
        }
        
        if rememberMe == "no" {
            let controller = TourViewController()
            controller.startRidingAction = {
                self.performSegue(withIdentifier: "segSignIn", sender: self)
            }
        } else {
            // user exists
            if let userMail = KeychainService.loadEmail() as String? {
                
                //Show activity indicator
                let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
                present(activityAlert, animated: false, completion: nil)
                
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
