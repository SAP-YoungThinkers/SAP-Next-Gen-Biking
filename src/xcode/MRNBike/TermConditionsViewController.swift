import UIKit

class TermConditionsViewController: UIViewController {
    @IBOutlet weak var cond_TextView: UITextView!
    @IBOutlet weak var termsConditionLabel: UILabel!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    
    var complete: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set text
        termsConditionLabel.text = "termConditionHeader".localized

        if let path = Bundle.main.path(forResource: "conditions", ofType: "txt") {
            if let content = try? String(contentsOfFile: path as String, encoding: String.Encoding.utf8) {
                cond_TextView.text = content
            }
        }
    }

    @IBAction func closeTerm(_ sender: Any) {
        if let complete = complete {
            complete()
        }
        self.close()
    }

    @IBAction func AgreeButton(_ sender: Any) {
        self.close()
    }
}
