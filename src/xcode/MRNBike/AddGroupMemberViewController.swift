import UIKit

class AddGroupMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var friends = [Friend]()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("addGroupMembersTitle", comment: "")
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.allowsMultipleSelectionDuringEditing = true;
        
        loadFriends()
    }
    
    func loadFriends() {
        
        if let userMail = KeychainService.loadEmail() as String? {
            
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
                    
                    self.friendsTableView.reloadData()
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
    
    //MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "AddMemberTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddGroupMemberTableViewCell  else {
            fatalError("Fatal Error")
        }
        
        // Fetches the appropriate friend for the data source layout.
        let friend = friends[indexPath.row]
        
        let name = friend.firstname + ", " + friend.lastname
        cell.friendNameLabel.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: Actions
    @IBAction func closePopUp(_ sender: Any) {
        dismiss()
    }
}
