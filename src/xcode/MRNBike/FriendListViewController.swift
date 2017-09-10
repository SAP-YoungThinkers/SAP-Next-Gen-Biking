import UIKit
import PopupDialog

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    //MARK: Properties
    var friends = [Friend]()
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        // TODO: Just for Testing, delete this function
//        mockFriendsData()

        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.allowsMultipleSelectionDuringEditing = false;

        //Remove separters if no friends
        friendsTableView.tableFooterView = UIView()
    }
    
//    // TODO: Just for Testing, delete this function
//    func mockFriendsData() {
//        let friend = Friend(firstname: "Ziad", lastname: "Ziad", photo: nil)
//        for _ in 0 ..< 10 {
//            friends.append(friend!)
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Request the friends from backend
        
        // TODO: Just for testing, uncomment this line
//        loadFriends()
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
        let cellIdentifier = "FriendTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FriendTableViewCell  else {
            fatalError("Fatal Error")
        }
        
        // Fetches the appropriate friend for the data source layout.
        let friend = friends[indexPath.row]
        
        cell.firstnameLabel.text = friend.firstname
        cell.lastnameLabel.text = friend.lastname
        cell.friendImage.image = friend.photo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    //Delete Friend action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: " x        ", handler: { (action, indexPath) in
            
            //Delete Alert
            let deleteAlert = UIAlertController(title: "Delete Friend", message: "Are you sure you want to delete that user?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                // Put your delete code here !
                

                self.friends.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
               
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)

        })
        deleteAction.backgroundColor = UIColor(red: 190/255, green: 51/255, blue: 43/255, alpha: 1)

        
        return [deleteAction]

    }
    
    //MARK: Private Methods
    
    private func loadFriends() {
        
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
                            guard let friendEntity = Friend(firstname: (friend["firstname"] as? String)!, lastname: (friend["lastname"] as? String)!, photo: UIImage(named: "selectphotoback")) else {
  
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
    
    
    //Added Library, PopupDialagoue
    
    @IBAction func openAddFriendPopup(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Social", bundle: nil)
        let ratingVC = storyboard.instantiateViewController(withIdentifier: "AddFriendPopupViewController")
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Present dialog
        present(popup, animated: true, completion: nil)

    }
}
