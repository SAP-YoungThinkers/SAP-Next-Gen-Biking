
import UIKit

class TourViewController: UIViewController {
    var startRidingAction: (() -> ())?
    
   /* @IBAction func startRidingPressed(_ sender: Any) {
        startRidingAction?()
        self.close()
  }*/
    
    
    @IBOutlet weak var wv: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
