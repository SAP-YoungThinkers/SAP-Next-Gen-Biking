import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet var friendImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Read ConfigList.plist
        var orangeColor = String()
        if let url = Bundle.main.url(forResource:"ConfigList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let swiftDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                orangeColor = swiftDictionary["orange"] as! String
            } catch {
                return
            }
        }
        
        // Blur Effect of Image Background
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurEffectView.frame = friendImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.7
        friendImage.addSubview(blurEffectView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
