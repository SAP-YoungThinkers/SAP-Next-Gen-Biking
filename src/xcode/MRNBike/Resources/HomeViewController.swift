import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var wheelRotationValue: UILabel!
    @IBOutlet weak var wheelRotationLabel: UILabel!
    @IBOutlet weak var burgerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var treesSavedLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var burgersLabel: UILabel!
    @IBOutlet weak var co2Label: UILabel!
    @IBOutlet weak var distanceText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        wheelRotationLabel.text = NSLocalizedString("wheelRotation", comment: "")
        burgersLabel.text = NSLocalizedString("burgersBurned", comment: "")
        distanceText.text = NSLocalizedString("distanceKM", comment: "")
        co2Label.text = NSLocalizedString("co2Saved", comment: "")
        myProfileButton.setTitle(NSLocalizedString("myProfile", comment: ""), for: .normal)
        startTrackingButton.setTitle(NSLocalizedString("startTracking", comment: ""), for: .normal)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Method to be called each time the screen appears to update the UI.
    private func updateUI() {
        print("hallo")
        // Setting The Username to the Label in Home Screen.
        let user = User.getUser()
        
        if let firstName = user.firstName {
            userNameLabel.text = firstName
        }
        print(user.wheelRotation as Any)
        print(user.co2Saved as Any)
        if let wheelRotation = user.wheelRotation {
            print(wheelRotation)
            wheelRotationValue.text = String(wheelRotation)
        }
        if let burgersBurned = user.burgersBurned {
            burgerLabel.text = String(burgersBurned)
        }
        if let distanceMade = user.distanceMade {
            distanceLabel.text = String(distanceMade)
        }
        if let co2Saved = user.co2Saved {
            treesSavedLabel.text = String(co2Saved)
        }
        
        //Updating the Picture in Homescreen.
        if let image = user.profilePicture {
            userImage.image = UIImage(data: image)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
