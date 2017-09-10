//
//  AddFriendPopupViewController.swift
//  MRNBike
//
//  Created by Ziad Abdelkader on 9/10/17.
//
//

import UIKit

class AddFriendPopupViewController: UIViewController {

    @IBOutlet weak var textFieldEmail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss()
    }
    
    
    @IBAction func inviteFriendAction(_ sender: UIButton) {
        invite()
    }
    
    
    //Add user in the backend
    
    func invite() {
        //get email adress from textfield
        //get user email from keychain.loademail
        
        let uploadData : [String: Any] = ["userId" : KeychainService.loadEmail(), "friendId" : textFieldEmail.text]
        
        //Generate json data for upload
        let jsonData = try! JSONSerialization.data(withJSONObject: uploadData)
        
        //Try create user in backend
        ClientService.postFriendRequest(scriptName: "sendFriendRequest.xsjs", relationship: jsonData) { (httpCode, error) in
            
            if error == nil {
                
                switch httpCode! {
                case 200: //Successful

                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("addedSuccessfullyTitle", comment: ""), message: NSLocalizedString("addedSuccessfullyMsg", comment: "")), animated: true, completion: {
                        self.textFieldEmail.text = ""
                    })
                    
                    break
                default: //For http error codes: 500
                    //Dismiss activity indicator

                    self.present(UIAlertCreator.infoAlert(title: NSLocalizedString("incorrectEmailTitle", comment: ""), message: NSLocalizedString("incorrectEmailMsg", comment: "")), animated: true, completion: nil)
                    
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
