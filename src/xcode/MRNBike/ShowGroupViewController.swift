import UIKit

class ShowGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var groupMemberTableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
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
    var groupMembers = [GroupMember]()
    
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
            groupNameTextfield.isUserInteractionEnabled = false
            timeTextfield.isUserInteractionEnabled = false
            startLocationTextfield.isUserInteractionEnabled = false
            destinationTextfield.isUserInteractionEnabled = false
            descriptionTextview.isUserInteractionEnabled = false
            saveButton.isEnabled = false
            saveButton.tintColor = UIColor.clear
        }
        
        groupMemberTableView.dataSource = self
        groupMemberTableView.delegate = self
        
        // delegate for hiding keyboard
        groupNameTextfield.delegate = self
        startLocationTextfield.delegate = self
        destinationTextfield.delegate = self
        descriptionTextview.delegate = self as? UITextViewDelegate
        
        //Hide Keyboard Extension
        self.hideKeyboardWhenTappedAround()
        
        //Bind textfields to validator
        groupNameTextfield.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        startLocationTextfield.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        destinationTextfield.addTarget(self, action:#selector(CreateProfileController.checkInput), for:UIControlEvents.editingChanged)
        
        groupMembers = (group?.members)!
    }
    
    //Check if inputs are syntactically valid
    func checkInput() {
        
        var valid = false
        
        let nameTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,40}$")
        let locationTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,50}$")
        let descriptionTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,300}$")
        
        //Check input fields and TermSwitcher
        if nameTest.evaluate(with: groupNameTextfield.text) && locationTest.evaluate(with: startLocationTextfield.text) && locationTest.evaluate(with: destinationTextfield.text) && descriptionTest.evaluate(with: descriptionTextview.text) {
            valid = true
        }
        
        if valid == true {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    
    //MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GroupMemberTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupMemberTableViewCell  else {
            fatalError("Fatal Error")
        }
        
        let group = groupMembers[indexPath.row]
        
        let name = group.firstname + ", " + group.lastname
        cell.groupMemberLabel.text = name
        
        return cell
    }
    
    //MARK: Actions
    @IBAction func saveChanges(_ sender: Any) {
        
        let name: String = groupNameTextfield.text!
        //let datum: String = groupNameTextfield.text!
        let startLocation: String = startLocationTextfield.text!
        let destination: String = destinationTextfield.text!
        let text: String = descriptionTextview.text!
        
        let data : [String: Any] = ["groupId": group?.id ?? "", "name": name, "datum": 1492173499999, "startLocation": startLocation, "destination": destination, "description": text, "privateGroup": group?.privateGroup ?? ""]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        
        ClientService.postGroup(scriptName: "updateGroup.xsjs", groupData: jsonData) { (httpCode, error) in
            if error == nil {
                switch httpCode! {
                case 200: //Successful
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("groupUpdatedTitle", comment: ""), message: NSLocalizedString("groupUpdatedMsg", comment: "")), animated: true, completion: nil)
                    break
                default: //For http error codes: 500
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                    return
                }
            }
            else
            {
                //An error occured in the app
                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
            }
        }
        
    }
}
