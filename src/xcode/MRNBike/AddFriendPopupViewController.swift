import UIKit

class AddFriendPopupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var enterMailLabel: UILabel!
    @IBOutlet weak var inviteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = NSLocalizedString("addFriend", comment: "")
        enterMailLabel.text = NSLocalizedString("enterEmail", comment: "")
        textFieldEmail.placeholder = NSLocalizedString("emailPlaceholder", comment: "")
        inviteBtn.setTitle(NSLocalizedString("addFriend", comment: ""), for: .normal)
        
        //Bind email textfield to validator
        textFieldEmail.addTarget(self, action:#selector(AddFriendPopupViewController.checkEmail), for:UIControlEvents.editingChanged)
        
        //Delegate for hiding keyboard
        textFieldEmail.delegate = self
        
        inviteBtn.isEnabled = false
        inviteBtn.alpha = 0.5
    }

    //Checks if email is valid
    func checkEmail() {
        var valid = false
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Z0-9a-z.-_]+\\.[A-Za-z]{2,5}")
        
        if emailTest.evaluate(with: textFieldEmail.text) {
            valid = true
        }
        
        if valid == true {
            inviteBtn.isEnabled = true
            inviteBtn.alpha = 1.0
        } else {
            inviteBtn.isEnabled = false
            inviteBtn.alpha = 0.5
        }
    }
    
    //Close keyboard
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func inviteFriendAction(_ sender: UIButton) {
        invite()
    }
    
    //Send friend request
    func invite() {

        let uploadData : [String: Any] = ["userId" : KeychainService.loadEmail() ?? "", "friendId" : textFieldEmail.text ?? ""]
        
        //Generate json data for upload
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
        //Send friend request
        ClientService.postFriendRequest(scriptName: "sendFriendRequest.xsjs", relationship: jsonData) { (httpCode, error) in
            
            if error == nil {
                switch httpCode! {
                case 200: //Successful
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("addedSuccessfullyTitle", comment: ""), message: NSLocalizedString("addedSuccessfullyMsg", comment: "")), animated: true, completion: {
                        self.textFieldEmail.text = ""
                    })
                    break
                default: //For http error codes: 500
                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("incorrectEmailTitle", comment: ""), message: NSLocalizedString("incorrectEmailMsg", comment: "")), animated: true, completion: {
                        self.textFieldEmail.text = ""
                    })
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
