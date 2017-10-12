import UIKit
import PopupDialog

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    //MARK: Properties
    var friends = [Friend]()
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FriendListViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.orange
        
        return refreshControl
    }()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.setTitle(NSLocalizedString("add", comment: ""), for: .normal)
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.allowsMultipleSelectionDuringEditing = false;
        friendsTableView.contentInset = UIEdgeInsets(top: 15,left: 0,bottom: 0,right: 0)
        
        loadFriends()
        
        self.friendsTableView.addSubview(self.refreshControl)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadFriends()
        self.friendsTableView.reloadData()
        refreshControl.endRefreshing()
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
        
        cell.firstnameLabel.text = "\(friend.firstname) \(friend.lastname)"
        
        //Set user image
        if let image = friend.photo {
            let img = UIImage(data: image)
            cell.friendImage.image = img
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Delete Friend action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: " X        ", handler: { (action, indexPath) in
            
            //Delete Alert
            let deleteAlert = UIAlertController(title: NSLocalizedString("deleteFriendTitle", comment: ""), message: NSLocalizedString("deleteFriendMsg", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
                
                if !(Reachability.isConnectedToNetwork()) {
                    // no Internet connection
                    self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
                } else {
                    ClientService.deleteFriend(userId: (KeychainService.loadEmail() ?? "") as String, friendId: self.friends[indexPath.row].email, completion: { (httpCode, error) in
                        if error == nil {
                            if(httpCode == 200) {
                                let alert = UIAlertCreator.infoAlertNoAction(title: NSLocalizedString("friendDeletedTitle", comment: ""), message: NSLocalizedString("friendDeletedMsg", comment: ""))
                                let gotItAction = UIAlertAction(title: NSLocalizedString("dialogActionGotIt", comment: ""), style: .default, handler: {
                                    (action) -> Void in
                                    self.friends.remove(at: indexPath.row)
                                    tableView.deleteRows(at: [indexPath], with: .automatic)
                                    self.loadFriends()
                                    self.friendsTableView.reloadData()
                                })
                                alert.addAction(gotItAction)
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                            }
                        } else {
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        }
                    })
                }
            }))
            
            deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
            
        })
        deleteAction.backgroundColor = UIColor(red: 190/255, green: 51/255, blue: 43/255, alpha: 1)
        
        
        return [deleteAction]
        
    }
    
    //MARK: Private Methods
    
    private func loadFriends() {
        
        if let userMail = KeychainService.loadEmail() as String? {
            
            if !(Reachability.isConnectedToNetwork()) {
                //An error occured in the app
                DispatchQueue.main.async {
                    // no Internet connection
                    self.present(UIAlertCreator.infoAlert(title: "", message: NSLocalizedString("ErrorNoInternetConnection", comment: "")), animated: true, completion: nil)
                }
            } else {
                //Show activity indicator
                let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
                DispatchQueue.main.async {
                    self.present(activityAlert, animated: false, completion: nil)
                }
                ClientService.getFriendList(mail: userMail, completion: { (data, error) in
                    if error == nil {
                        
                        let user = User.getUser()
                        
                        //Clear friends array
                        self.friends.removeAll()
                        user.friendList.removeAll()
                        
                        guard let responseData = data else {
                            DispatchQueue.main.async {
                                //Dismiss activity indicator
                                activityAlert.dismiss(animated: false, completion: nil)
                            }
                            //An error occured in the app
                            DispatchQueue.main.async {
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                            }
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
                                    
                                    DispatchQueue.main.async {
                                        //Dismiss activity indicator
                                        activityAlert.dismiss(animated: false, completion: nil)
                                    }
                                    //An error occured in the app
                                    DispatchQueue.main.async {
                                        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                                    }
                                    return
                                }
                                self.friends.append(friendEntity)
                                user.friendList.append(friendEntity)
                            }
                        }
                        
                        self.friendsTableView.reloadData()
                        DispatchQueue.main.async {
                            //Dismiss activity indicator
                            activityAlert.dismiss(animated: false, completion: nil)
                        }
                    } else {
                        if error == ClientServiceError.notFound {
                            DispatchQueue.main.async {
                                //Dismiss activity indicator
                                activityAlert.dismiss(animated: false, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                //Dismiss activity indicator
                                activityAlert.dismiss(animated: false, completion: nil)
                            }
                            
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
