import UIKit

class ShowGroupViewController: UIViewController {

    var group = Group(id: 0, name: "", datum: "", startLocation: "", destination: "", text: "", owner: "", privateGroup: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func backButton(_ sender: Any) {
         self.dismiss()
    }
}
