import UIKit

class CreateGroupPopUpViewController: UIViewController {

    
    //Mark: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //createGroupTitleLabel.text = NSLocalizedString("createGroupTitle", comment: "")
    }
    
    //Mark: Action
    @IBAction func closePopUp(_ sender: Any) {
        dismiss()
    }
}
