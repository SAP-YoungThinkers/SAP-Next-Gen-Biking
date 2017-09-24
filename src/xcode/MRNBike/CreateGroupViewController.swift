import UIKit
import PopupDialog

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var createGroupButton: UIBarButtonItem!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var privateGroupSwitch: UISwitch!
    
    //Labels
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var privateGroupLabel: UILabel!
    
    //Textfields, textview
    @IBOutlet weak var groupNameTextfield: UITextField!
    @IBOutlet weak var timeTextfield: UITextField!
    @IBOutlet weak var startLocationTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var descriptionTextview: UITextView!
    
    var groupMembers = [String]()
    var datePickerValue = Date()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("createGroupTitle", comment: "")
        
        //Labeltext
        groupNameLabel.text = NSLocalizedString("groupName", comment: "")
        timeLabel.text = NSLocalizedString("journeyTime", comment: "")
        startLocationLabel.text = NSLocalizedString("startLocation", comment: "")
        destinationLabel.text = NSLocalizedString("destination", comment: "")
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        privateGroupLabel.text = NSLocalizedString("privateGroup", comment: "")
        addFriendsButton.setTitle(NSLocalizedString("addGroupMembersTitle", comment: ""), for: .normal)
        
        //Textfield text color
        groupNameTextfield.textColor = UIColor.lightGray
        timeTextfield.textColor = UIColor.lightGray
        startLocationTextfield.textColor = UIColor.lightGray
        destinationTextfield.textColor = UIColor.lightGray
        descriptionTextview.textColor = UIColor.lightGray
        
        //Textfields placeholders
        groupNameTextfield.placeholder = NSLocalizedString("groupNamePlaceholder", comment: "")
        startLocationTextfield.placeholder = NSLocalizedString("groupStartLocationPlaceholder", comment: "")
        destinationTextfield.placeholder = NSLocalizedString("groupDestinationPlaceholder", comment: "")
        descriptionTextview.text = NSLocalizedString("groupDescriptionPlaceholder", comment: "")
        descriptionTextview.textColor = UIColor.lightGray
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02")
        let date = Date()
        timeTextfield.text = dateFormatter.string(from: date)
        datePickerValue = date
        
        createGroupButton.isEnabled = false
        
        privateGroupSwitch.isOn = false
        
        //Delegate for hiding keyboard
        groupNameTextfield.delegate = self
        startLocationTextfield.delegate = self
        destinationTextfield.delegate = self
        descriptionTextview.delegate = self
        
        //Hide Keyboard Extension when tapped arround
        self.hideKeyboardWhenTappedAround()
        
        //Bind textfields to validator
        groupNameTextfield.addTarget(self, action:#selector(CreateGroupViewController.checkInput), for:UIControlEvents.editingChanged)
        startLocationTextfield.addTarget(self, action:#selector(CreateGroupViewController.checkInput), for:UIControlEvents.editingChanged)
        destinationTextfield.addTarget(self, action:#selector(CreateGroupViewController.checkInput), for:UIControlEvents.editingChanged)
    }
    
    //Check if inputs are syntactically valid
    func checkInput() {
        var valid = false
        
        let nameTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,40}$")
        let locationTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,50}$")
        
        //Check input fields and TermSwitcher
        if nameTest.evaluate(with: groupNameTextfield.text) && locationTest.evaluate(with: startLocationTextfield.text) && locationTest.evaluate(with: destinationTextfield.text) && descriptionTextview.textColor != UIColor.lightGray {
            valid = true
        }
        
        if valid == true {
            createGroupButton.isEnabled = true
        } else {
            createGroupButton.isEnabled = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let descriptionTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,300}$")
        var valid = false
        
        if descriptionTest.evaluate(with: descriptionTextview.text!) {
            valid = true
        }
        
        if valid == true {
            createGroupButton.isEnabled = true
        } else {
            createGroupButton.isEnabled = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("groupDescriptionPlaceholder", comment: "")
            textView.textColor = UIColor.lightGray
        }
    }
    
    //Close keyboard
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    @IBAction func timeTextFieldEditing(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(CreateGroupViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02")
        timeTextfield.text = dateFormatter.string(from: sender.date)
        datePickerValue = sender.date
    }
   
    //MARK: Actions
    @IBAction func createGroup(_ sender: Any) {
        let name: String = groupNameTextfield.text!
        //let datum: String = groupNameTextfield.text!
        let startLocation: String = startLocationTextfield.text!
        let destination: String = destinationTextfield.text!
        let text: String = descriptionTextview.text!
        
        let timeInterval = datePickerValue.timeIntervalSince1970
        let timestamp = String(Int(timeInterval))
        
        var jsonData = Data()
        
        var privateGroup = 0
        
        if privateGroupSwitch.isOn {
            privateGroup = 1
        }
        
        do {
            groupMembers.append(KeychainService.loadEmail()! as String)
            
            let data : [String: Any] = ["name": name, "datum": timestamp, "startLocation": startLocation, "destination": destination, "description": text, "owner": KeychainService.loadEmail()! as String, "privateGroup": privateGroup, "members": groupMembers]
            
            jsonData = try JSONSerialization.data(withJSONObject: data)
        } catch {
            let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: ""))
            let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                (action) -> Void in
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(gotItAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        ClientService.postGroup(scriptName: "createGroup.xsjs", groupData: jsonData) { (httpCode, error) in
            if error == nil {
                switch httpCode! {
                case 200: //Successful
                    let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("groupCreatedTitle", comment: ""), message: NSLocalizedString("groupCreatedMsg", comment: ""))
                    let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                        (action) -> Void in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(gotItAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                default: //For http error codes: 500
                    let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: ""))
                    let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                        (action) -> Void in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(gotItAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else
            {
                //An error occured in the app
                let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: ""))
                let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                    (action) -> Void in
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(gotItAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func openAddFriendsDialog(_ sender: UIButton) {
        /*
        let storyboard = UIStoryboard(name: "Social", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddGroupMember")
        
        // Create the dialog
        let popup = PopupDialog(viewController: viewController, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: false)
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
 */
    }
}
