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
    
        friendImage.layer.cornerRadius = friendImage.bounds.height / 2
        friendImage.clipsToBounds = true
        friendImage.borderWidth = 1
        friendImage.borderColor = UIColor(hexString: orangeColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
