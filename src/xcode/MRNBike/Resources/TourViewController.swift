
import UIKit

protocol PushViewControllerDelegate: class {
    func dismissViewController(_ controller: UIViewController)
}

class TourViewController: UIViewController {
    
    var delegate: PushViewControllerDelegate!
    @IBAction func startRidingPressed(_ sender: UIButton) {
        print("pressed.....")
        if self.delegate != nil {
            self.delegate.dismissViewController(self)
        }
    }
    
    @IBOutlet weak var wv: UIWebView!
    @IBOutlet weak var startRidingButton: UIButton!
    @IBOutlet weak var takeTourLabel: UILabel!
    @IBOutlet weak var takeTourText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set text
        takeTourLabel.text = NSLocalizedString("takeTourHeader", comment: "")
        takeTourText.text = NSLocalizedString("takeTourDescription", comment: "")
        startRidingButton.setTitle(NSLocalizedString("startRidingButton", comment: ""), for: .normal)
        //the youtube code of the video, will be changed later
        loadYoutube(videoID: "93obZ3ymguY")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func loadYoutube(videoID:String) {
        guard
            let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)")
            else { return }
        wv.loadRequest( URLRequest(url: youtubeURL) ) 
    }
    
    
}


protocol View1Delegate: class {
    func dismissViewController(controller: UIViewController)
}
