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
        
        // Setting The Username to the Label in Home Screen.
        
        if let firstName = UserDefaults.standard.string(forKey: "userFirstName") {
            userNameLabel.text = firstName
        }
        if let lastName = UserDefaults.standard.string(forKey: "userSurname"), let label = userNameLabel.text {
            userNameLabel.text = "\(label) \(lastName)"
        }
        
        //Updating the Picture in Homescreen.
        
        let imageData = UserDefaults.standard.value(forKey: "userProfileImage")
        if let image = imageData as? Data {
            userImage.image = UIImage(data: image)
        }
        
        //Updating the labels after each tracking.
        wheelRotationValue.text = String(UserDefaults.standard.integer(forKey: "wheelRotation"))
        burgerLabel.text = String(UserDefaults.standard.double(forKey: "burgers"))
        distanceLabel.text = String(UserDefaults.standard.double(forKey: "distance"))
        treesSavedLabel.text = String(UserDefaults.standard.double(forKey: "treesSaved"))
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
