import UIKit

class ShowGroupViewController: UIViewController {

    //MARK: Properties
    
    //Label
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    
    //Textfields, textview
    @IBOutlet weak var groupNameTextfield: UITextField!
    @IBOutlet weak var timeTextfield: UITextField!
    @IBOutlet weak var startLocationTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var descriptionTextview: UITextView!
    
    var group: Group?
    
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("groupDetailsTitle", comment: "")
        
        groupNameLabel.text = NSLocalizedString("groupName", comment: "")
        timeLabel.text = NSLocalizedString("journeyTime", comment: "")
        startLocationLabel.text = NSLocalizedString("startLocation", comment: "")
        destinationLabel.text = NSLocalizedString("destination", comment: "")
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        membersLabel.text = NSLocalizedString("memberList", comment: "")
        
        groupNameTextfield.text = group?.name
        timeTextfield.text = group?.datum
        startLocationTextfield.text = group?.startLocation
        destinationTextfield.text = group?.destination
        descriptionTextview.text = group?.text
        
        if(group?.owner != KeychainService.loadEmail()! as String){
            groupNameTextfield.isEnabled = false
            timeTextfield.isEnabled = false
            startLocationTextfield.isEnabled = false
            destinationTextfield.isEnabled = false
            descriptionTextview.isEditable = false
        }
        
        
        print(group?.members[0] ?? "falsch")
        print(group?.members[0].email ?? "falsch")
        print(group?.members[0].firstname ?? "falsch")
        print(group?.members[0].lastname ?? "falsch")
    }
}
