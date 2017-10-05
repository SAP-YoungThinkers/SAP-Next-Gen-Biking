import UIKit


class StartPageViewController: UIViewController, PushViewControllerDelegate, CredentialsHandoverDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var takeTourButton: UIButton!
    
    private var passMail = false
    private var passPassword = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tourModal" {
            let controller = segue.destination as! TourViewController
            controller.delegate = self
        } else if let destination = segue.destination as? FirstLogInViewController {
            destination.delegate = self
        }
    }
    
    func handOverData() -> [String?] {
        let m = KeychainService.loadEmail() as String?
        let p = KeychainService.loadPassword() as String?
        return [passMail ? (m != nil ? m : nil) : nil, passPassword ? (p != nil ? p : nil) : nil]
    }
    
    func dismissViewController(_ controller: UIViewController) {
        print("function wurde aufgerufen")
        controller.dismiss(animated: true) { () -> Void in
            // push to login
            self.performSegue(withIdentifier: "fromStartToLogin", sender: nil)
            print("\n\n\n\n\nyes it worked!!!!!\n\n\n\n\n")
        }
    }
    
    func errorDiag() {
        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set text
        startButton.setTitle(NSLocalizedString("start", comment: ""), for: .normal)
        takeTourButton.setTitle(NSLocalizedString("takeTour", comment: ""), for: .normal)
        
        self.navigationController?.isNavigationBarHidden = true
        
        var tryLogin = false
        if let li = KeychainService.loadLoginStatus() {
            if li != "false" {
                tryLogin = true
            }
        } else {
            tryLogin = true
        }
        
        if tryLogin {
            // internet?
            if Reachability.isConnectedToNetwork() {
                
                // if user and mail
                if let userMail = KeychainService.loadEmail() {
                    if let userPassword = KeychainService.loadPassword() {
                        
                        let uploadData : [String: Any] = ["email" : userMail, "password" : userPassword]
                        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
                        
                        ClientService.postUser(scriptName: "verifyUser.xsjs", userData: jsonData) { (httpCode, error) in
                            if error == nil {
                                switch httpCode! {
                                case 200:
                                    // User verified, update!
                                    ClientService.getUser(mail: userMail as String, completion: { (data, error) in
                                        if error == nil {
                                            guard let responseData = data else {
                                                //An error occured
                                                return
                                            }
                                            User.createSingletonUser(userData: responseData)
                                            print("KEYCHAIN STATUS: \(KeychainService.loadLoginStatus())")
                                            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                            let controller = storyboard.instantiateViewController(withIdentifier: "Home")
                                            self.present(controller, animated: true, completion: nil)
                                        }
                                    })
                                    break
                                default:
                                    // JSON wrong or empty: 500
                                    break
                                }
                            }
                        }
                        
                    }
                    
                }
                
            }
        }
        
        // remember me?
        if let remember = KeychainService.loadRemember() {
            switch remember {
            case "yes":
                // insert password / mail into fields!
                print("now i would have to insert credentials")
                passMail = true
                passPassword = true
                break
            default:
                // do nothing... login please!
                break
            }
        }
        
    }
}
