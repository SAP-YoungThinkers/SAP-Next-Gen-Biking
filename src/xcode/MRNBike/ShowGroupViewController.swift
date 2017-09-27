import UIKit

class ShowGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Properties
    //Tables
    @IBOutlet weak var groupMemberTableView: UITableView!
    @IBOutlet weak var addFriendsTable: UITableView!
    
    //Buttons and other controls
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var privateGroupSwitch: UISwitch!
    @IBOutlet weak var changeTableSegment: UISegmentedControl!
    
    //Label
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var privateGroupLabel: UILabel!
    @IBOutlet weak var addMemberLabel: UILabel!
    
    //Textfields, textview
    @IBOutlet weak var groupNameTextfield: UITextField!
    @IBOutlet weak var timeTextfield: UITextField!
    @IBOutlet weak var startLocationTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var descriptionTextview: UITextView!
    
    var group: Group?
    var groupMembers = [GroupMember]()
    var friends = [Friend]()
    var datePickerValue = Date()
    var orangeColor = String()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set friend list and group member list
        let user = User.getUser()
        friends = user.friendList
        groupMembers = (group?.members)!
        
        //Remove already group members from local friendlist to avoid duplicates
        var seen = Set<String>()
        var unique = [Friend]()
        
        for member in groupMembers {
            seen.insert(member.email)
        }
        
        for friend in friends {
            if !seen.contains(friend.email) {
                unique.append(friend)
                seen.insert(friend.email)
            }
        }
        
        friends = unique
        
        self.navigationItem.title = NSLocalizedString("groupDetailsTitle", comment: "")
        
        groupNameLabel.text = NSLocalizedString("groupName", comment: "")
        timeLabel.text = NSLocalizedString("journeyTime", comment: "")
        startLocationLabel.text = NSLocalizedString("startLocation", comment: "")
        destinationLabel.text = NSLocalizedString("destination", comment: "")
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        privateGroupLabel.text = NSLocalizedString("privateGroup", comment: "")
        addMemberLabel.text = NSLocalizedString("memberList", comment: "")
        changeTableSegment.setTitle(NSLocalizedString("segmentShowMemberTitle", comment: ""), forSegmentAt: 0)
        changeTableSegment.setTitle(NSLocalizedString("segmentAddMemberTitle", comment: ""), forSegmentAt: 1)
        
        groupNameTextfield.text = group?.name
        timeTextfield.text = group?.datum
        startLocationTextfield.text = group?.startLocation
        destinationTextfield.text = group?.destination
        descriptionTextview.text = group?.text
        if group?.privateGroup == 0 {
            privateGroupSwitch.isOn = false
        } else {
            privateGroupSwitch.isOn = true
        }
        
        let inte = Int((group?.datum)!)
        let timeInterval = Double(inte!)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02")
        timeTextfield.text = dateFormatter.string(from: date)
        datePickerValue = date
        
        groupNameTextfield.textColor = UIColor.lightGray
        timeTextfield.textColor = UIColor.lightGray
        startLocationTextfield.textColor = UIColor.lightGray
        destinationTextfield.textColor = UIColor.lightGray
        descriptionTextview.textColor = UIColor.lightGray
        
        groupNameTextfield.isUserInteractionEnabled = false
        timeTextfield.isUserInteractionEnabled = false
        startLocationTextfield.isUserInteractionEnabled = false
        destinationTextfield.isUserInteractionEnabled = false
        descriptionTextview.isUserInteractionEnabled = false
        privateGroupSwitch.isEnabled = false
        changeTableSegment.isEnabled = false
        
        let barButton = saveButton
        barButton?.title = "Edit"
        barButton?.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = barButton
        
        if(group?.owner != KeychainService.loadEmail()! as String){
            if !privateGroupSwitch.isOn {
                saveButton.isEnabled = true
            } else {
                saveButton.tintColor = UIColor.clear
            }
        }
        
        //Tables
        groupMemberTableView.dataSource = self
        groupMemberTableView.delegate = self
        addFriendsTable.dataSource = self
        addFriendsTable.delegate = self
        addFriendsTable.isHidden = true
        addFriendsTable.allowsMultipleSelectionDuringEditing = true;
        addFriendsTable.setEditing(true, animated: false)
        
        //Delegate for hiding keyboard
        groupNameTextfield.delegate = self
        timeTextfield.delegate = self
        startLocationTextfield.delegate = self
        destinationTextfield.delegate = self
        descriptionTextview.delegate = self
        
        //Hide Keyboard Extension
        self.hideKeyboardWhenTappedAround()
        
        //Bind textfields to validator
        groupNameTextfield.addTarget(self, action:#selector(ShowGroupViewController.checkInput), for:UIControlEvents.editingChanged)
        startLocationTextfield.addTarget(self, action:#selector(ShowGroupViewController.checkInput), for:UIControlEvents.editingChanged)
        destinationTextfield.addTarget(self, action:#selector(ShowGroupViewController.checkInput), for:UIControlEvents.editingChanged)
        privateGroupSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        
        //Read ConfigList.plist
        if let url = Bundle.main.url(forResource:"ConfigList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let swiftDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                orangeColor = swiftDictionary["orange"] as! String
            } catch {
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        let user = User.getUser()
        friends = user.friendList
        //Remove already group members from local friendlist to avoid duplicates
        var seen = Set<String>()
        var unique = [Friend]()
        
        for member in groupMembers {
            seen.insert(member.email)
        }
        
        for friend in friends {
            if !seen.contains(friend.email) {
                unique.append(friend)
                seen.insert(friend.email)
            }
        }
        
        friends = unique
    }
    
    //Check if inputs are syntactically valid
    func checkInput() {
        
        var valid = false
        
        let nameTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,40}$")
        let locationTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,50}$")
        
        //Check input fields and TermSwitcher
        if nameTest.evaluate(with: groupNameTextfield.text) && locationTest.evaluate(with: startLocationTextfield.text) && locationTest.evaluate(with: destinationTextfield.text) {
            valid = true
        }
        
        if valid == true {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let descriptionTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[a-zA-ZäÄüÜöÖß0-9,.:;!-?=()\\s]{5,300}$")
        
        var valid = false
        
        if descriptionTest.evaluate(with: descriptionTextview.text!) {
            valid = true
        }
        
        if valid == true {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func switchValueDidChange() {
        saveButton.isEnabled = true
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
    
    //MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.groupMemberTableView {
            return groupMembers.count
        } else {
            return friends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.groupMemberTableView {
            let cellIdentifier = "GroupMemberTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupMemberTableViewCell  else {
                fatalError("Fatal Error")
            }
            
            let group = groupMembers[indexPath.row]
            
            let name = group.firstname + ", " + group.lastname
            cell.groupMemberLabel.text = name
            
            return cell
        } else {
            let cellIdentifier = "AddFriendTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FriendTableViewCell  else {
                fatalError("Fatal Error")
            }
            
            // Fetches the appropriate friend for the data source layout.
            let friend = friends[indexPath.row]
            
            cell.firstnameLabel.text = friend.firstname
            cell.lastnameLabel.text = friend.lastname
            
            //Set user image
            if let image = friend.photo {
                let img = UIImage(data: image)
                cell.friendImage.image = img
            }
            
            cell.tintColor = UIColor(hexString: orangeColor)
            
            return cell
        }
    }
    
    //MARK: Actions
    
    //Switch tables action
    @IBAction func indexChangedSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            groupMemberTableView.isHidden = false
            addFriendsTable.isHidden = true
        case 1:
            groupMemberTableView.isHidden = true
            addFriendsTable.isHidden = false
        default:
            break
        }
    }
    
    //Upload changes to backend
    @IBAction func saveChanges(_ sender: Any) {
        if (saveButton.title == "Edit") {
            if(group?.owner != KeychainService.loadEmail()! as String){
                if !privateGroupSwitch.isOn {
                    let barButton = saveButton
                    barButton?.title = "Save"
                    barButton?.tintColor = UIColor(hexString: "27AE60")
                    navigationItem.rightBarButtonItem = barButton
                    
                    changeTableSegment.isEnabled = true
                }
            } else {
                let barButton = saveButton
                barButton?.title = "Save"
                barButton?.tintColor = UIColor(hexString: "27AE60")
                navigationItem.rightBarButtonItem = barButton
                
                groupNameTextfield.isUserInteractionEnabled = true
                timeTextfield.isUserInteractionEnabled = true
                startLocationTextfield.isUserInteractionEnabled = true
                destinationTextfield.isUserInteractionEnabled = true
                descriptionTextview.isUserInteractionEnabled = true
                privateGroupSwitch.isEnabled = true
                changeTableSegment.isEnabled = true
            }
        } else {
            if !(Reachability.isConnectedToNetwork()) {
                // no Internet connection
                self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
            } else {
                let name: String = groupNameTextfield.text!
                //let datum: String = groupNameTextfield.text!
                let startLocation: String = startLocationTextfield.text!
                let destination: String = destinationTextfield.text!
                let text: String = descriptionTextview.text!
                
                let timeInterval = datePickerValue.timeIntervalSince1970
                let timestamp = String(Int(timeInterval))
                
                var privateGroup = 0
                
                if privateGroupSwitch.isOn {
                    privateGroup = 1
                }
                
                var friendsSelected = [String]()
                
                if addFriendsTable.indexPathsForSelectedRows != nil {
                    let selectedRows = addFriendsTable.indexPathsForSelectedRows
                    for indexPath in selectedRows! {
                        friendsSelected.append(friends[indexPath.row].email)
                    }
                }
                
                var jsonData = Data()
                
                do {
                    let id = group?.id
                    let data : [String: Any] = ["groupId": id!, "name": name, "datum": timestamp, "startLocation": startLocation, "destination": destination, "description": text, "privateGroup": privateGroup, "members": friendsSelected]
                    
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
                
                ClientService.postGroup(scriptName: "updateGroup.xsjs", groupData: jsonData) { (httpCode, error) in
                    if error == nil {
                        switch httpCode! {
                        case 200: //Successful
                            self.saveButton.isEnabled = false
                            
                            let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("groupUpdatedTitle", comment: ""), message: NSLocalizedString("groupUpdatedMsg", comment: ""))
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
                            return
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
        }
    }
}
