

import UIKit

class TermConditionsViewController: UIViewController {
    @IBOutlet weak var cond_TextView: UITextView!
    @IBOutlet weak var termsConditionLabel: UILabel!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set text
        termsConditionLabel.text = NSLocalizedString("termConditionHeader", comment: "")
        cond_TextView.text = NSLocalizedString("termConditionText", comment: "")
        agreeButton.setTitle(NSLocalizedString("agreeButton", comment: ""), for: .normal)
        disagreeButton.setTitle(NSLocalizedString("disagreeButton", comment: ""), for: .normal)
        
        // Do any additional setup after loading the view.
        if let path = Bundle.main.path(forResource: "conditions", ofType: "txt") {
            if let content = try? String(contentsOfFile: path as String, encoding: String.Encoding.utf8) {
                cond_TextView.text = content
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeTerm(_ sender: Any) {
        
        let termAlert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        termAlert.title = "Dismiss conformation"
        termAlert.message = "If you disagree with term conditions, you can't continue work with the App and your current progress will be lost. Are you sure about this?"
        termAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {action in
            return
        }))
        termAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {action in
            let storyboard = UIStoryboard(name: "StartPage", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "StartPage")
            self.present(controller, animated: true, completion: nil)
        }))
        self.present(termAlert, animated: true, completion: nil)
        return
      
    }


    @IBAction func AgreeButton(_ sender: Any) {
    self.close()
    }


}
