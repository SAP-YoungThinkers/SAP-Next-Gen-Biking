
import UIKit

class TourViewController: UIViewController {
    var startRidingAction: (() -> ())?
    
   /* @IBAction func startRidingPressed(_ sender: Any) {
        startRidingAction?()
        self.close()
  }*/
    
    
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
        loadYoutube(videoID: "7iT9fueKCJM")
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
