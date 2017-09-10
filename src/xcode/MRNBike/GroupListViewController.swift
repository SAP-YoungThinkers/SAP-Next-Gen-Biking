import UIKit
import PopupDialog

class GroupListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    var groups = [Group]()
    
    
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var createGroupBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGroupBtn.setTitle(NSLocalizedString("createGroupBtn", comment: ""), for: .normal)
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Request the groups from backend
        loadGroups()
    }
    
    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroupTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupTableViewCell  else {
            fatalError("Fatal Error")
        }
        
        // Fetches the appropriate friend for the data source layout.
        let friend = groups[indexPath.row]
        
        cell.nameLabel.text = friend.name
        cell.timeLocationLabel.text = friend.time
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadGroups() {
        
        if let userMail = KeychainService.loadEmail() as String? {
            
            //Show activity indicator
            let activityAlert = UIAlertCreator.waitAlert(message: NSLocalizedString("pleaseWait", comment: ""))
            present(activityAlert, animated: false, completion: nil)
            
            ClientService.getGroupList(mail: userMail, completion: { (data, error) in
                if error == nil {
                    //Clear friends array
                    self.groups.removeAll()
                    
                    guard let responseData = data else {
                        //Dismiss activity indicator
                        activityAlert.dismiss(animated: false, completion: nil)
                        //An error occured
                        self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                        return
                    }
                    
                    //Construct group array
                    if let groupList = responseData["groups"] as? [[String: AnyObject]] {
                        for group in groupList {
                            guard let groupEntity = Group(name: (group["name"] as? String)!, time: (group["datum"] as? String)!) else {
                                
                                activityAlert.dismiss(animated: false, completion: nil)
                                //An error occured
                                self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("errorOccuredDialogTitle", comment: ""), message: NSLocalizedString("errorOccuredDialogMsg", comment: "")), animated: true, completion: nil)
                                return
                            }
                            self.groups.append(groupEntity)
                        }
                    }
                    
                    self.groupTableView.reloadData()
                    //Dismiss activity indicator
                    activityAlert.dismiss(animated: false, completion: nil)
                    
                } else {
                    if error == ClientServiceError.notFound {
                        //Dismiss activity indicator
                        activityAlert.dismiss(animated: false, completion: nil)
                        
                        //An error occured in the app
                        DispatchQueue.main.async {
                            self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("noGroupsDialogTitle", comment: ""), message: NSLocalizedString("noGroupsDialogMsg", comment: "")), animated: true, completion: nil)
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
    
    //MARK: Actions
    
    @IBAction func onPressOpenCreateGroup(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Social", bundle: nil)
        let ratingVC = storyboard.instantiateViewController(withIdentifier: "CreateGroupPopupViewController")
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Present dialog
        present(popup, animated: true, completion: nil)
        
    }
    
    
}
