import UIKit
import PopupDialog

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var createGroupButton: UIBarButtonItem!
    @IBOutlet weak var privateGroupSwitch: UISwitch!
    
    //Labels
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var privateGroupLabel: UILabel!
    @IBOutlet weak var addMemberLabel: UILabel!
    
    //Textfields, textview
    @IBOutlet weak var groupNameTextfield: UITextField!
    @IBOutlet weak var timeTextfield: UITextField!
    @IBOutlet weak var startLocationTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var descriptionTextview: UITextView!
    
    //Table
    @IBOutlet weak var addFriendsTable: UITableView!
    
    var friends = [Friend]()
    var groupMembers = [String]()
    var datePickerValue = Date()
    var orangeColor = String()
    var greyColor = String()
    
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
        addMemberLabel.text = NSLocalizedString("selectMembers", comment: "")
        
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
        
        //Table delegate
        addFriendsTable.dataSource = self
        addFriendsTable.delegate = self
        addFriendsTable.allowsMultipleSelectionDuringEditing = true;
        addFriendsTable.setEditing(true, animated: false)
        
        //Read ConfigList.plist
        if let url = Bundle.main.url(forResource:"ConfigList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let swiftDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                orangeColor = swiftDictionary["orange"] as! String
                greyColor = swiftDictionary["greyBackground"] as! String
            } catch {
                return
            }
        }
        
        loadFriends()
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
    
    //MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
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
    
    private func loadFriends() {
        
        if let userMail = KeychainService.loadEmail() as String? {
            
            if !(Reachability.isConnectedToNetwork()) {
                // no Internet connection
                self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
            } else {
                //Show activity indicator
                let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
                present(activityAlert, animated: false, completion: nil)
                
                ClientService.getFriendList(mail: userMail, completion: { (data, error) in
                    if error == nil {
                        
                        //Clear friends array
                        self.friends.removeAll()
                        
                        guard let responseData = data else {
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            //An error occured
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                            return
                        }
                        
                        //Construct friends array
                        if let friendList = responseData["friendList"] as? [[String: AnyObject]] {
                            for friend in friendList {
                                
                                var img: Data?
                                if let image = friend["image"] as? String {
                                    img = Data(base64Encoded: image)
                                }
                                
                                guard let friendEntity = Friend(email: (friend["eMail"] as? String)!, firstname: (friend["firstname"] as? String)!, lastname: (friend["lastname"] as? String)!, photo: img!) else {
                                    
                                    activityAlert.dismiss(animated: false, completion: nil)
                                    //An error occured
                                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                                    return
                                }
                                self.friends.append(friendEntity)
                            }
                        }
                        
                        self.addFriendsTable.reloadData()
                        //Dismiss activity indicator
                        activityAlert.dismiss(animated: false, completion: nil)
                    } else {
                        if error == ClientServiceError.notFound {
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            
                            //An error occured in the app
                            DispatchQueue.main.async {
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("noFriendsDialogTitle", comment: ""), message: NSLocalizedString("noFriendsDialogMsg", comment: "")), animated: true, completion: nil)
                            }
                        } else {
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                            
                            //An error occured in the app
                            DispatchQueue.main.async {
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                            }
                        }
                    }
                })
            }
        }
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
            
            if addFriendsTable.indexPathsForSelectedRows != nil {
                let selectedRows = addFriendsTable.indexPathsForSelectedRows
                for indexPath in selectedRows! {
                    groupMembers.append(friends[indexPath.row].email)
                }
            }
            
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
}
