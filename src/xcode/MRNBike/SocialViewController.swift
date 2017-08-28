import UIKit

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    var friends = [Friend]()
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        //Request the friends from backend
        loadFriends()
        
        //title
        self.navigationItem.title = NSLocalizedString("socialFriendsTitle", comment: "")
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
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let friend = friends[indexPath.row]
        
        cell.firstnameLabel.text = friend.firstname
        cell.lastnameLabel.text = friend.lastname
        cell.friendImage.image = friend.photo
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadFriends() {
        
        if let userMail = KeychainService.loadEmail() as String? {
            
            //Show activity indicator
            let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
            present(activityAlert, animated: false, completion: nil)
            
            ClientService.getFriendList(mail: userMail, completion: { (data, error) in
                if error == nil {
                    
                    guard let responseData = data else {
                        //Dismiss activity indicator
                        activityAlert.dismiss(animated: false, completion: nil)
                        //An error occured
                        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        return
                    }

                    if let friendList = responseData["friendList"] as? [[String: AnyObject]] {
                        for friend in friendList {
                            guard let friendEntity = Friend(firstname: (friend["firstname"] as? String)!, lastname: (friend["lastname"] as? String)!, photo: nil) else {
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
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false, completion: nil)
                    
                    //An error occured
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                }
            })
        }
    }
}
