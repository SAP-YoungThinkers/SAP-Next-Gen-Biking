import Foundation

class User {
    
    var surname: String?
    var firstName: String?
    var userWeight: Int?
    var userWheelSize: Int?
    var shareInfo: Int?
    var profilePicture : Data? // as JPEG data stream of UIImage
    //private var accountPicturePath: String? = nil
    
    var wheelRotation: Int?
    var burgersBurned: Double?
    var distanceMade: Double?
    var co2Saved: Int?
    
    private static var isSingleton: Bool = false
    private static var singletonUser: User? = nil
    
    private init(userData: [String: AnyObject]?) {

        if let userArray = userData?["entity"] as? [[String: AnyObject]] {
            
            for user in userArray {
                
                if let surname = user["lastname"] as? String {
                    self.surname = surname
                }
                if let firstname = user["firstname"] as? String {
                    self.firstName = firstname
                }
                if let weight = user["weight"] as? Int {
                    self.userWeight = weight
                }
                if let wsize = user["wheelSize"] as? Int {
                    self.userWheelSize = wsize
                }
                if let wheelRotation = user["wheelRotation"] as? Int {
                    self.wheelRotation = wheelRotation
                }
                if let burgersBurned = user["burgersBurned"] as? Double {
                    self.burgersBurned = burgersBurned
                }
                if let distanceMade = user["distanceMade"] as? Double {
                    self.distanceMade = distanceMade
                }
                if let co2Saved = user["co2Saved"] as? Int {
                    self.co2Saved = co2Saved
                }
                
                if let allow = user["allowShare"] as? Int {
                    self.shareInfo = allow
                }
                User.isSingleton = true
            }
        }
    }
    
    static func createSingletonUser(userData: [String: AnyObject]?) {
        if User.isSingleton != true {
            let user = User(userData: userData)
            User.singletonUser = user
        }
    }
    
    static func getUser() -> User {
        return singletonUser!
    }
    
    static func deleteSingleton() {
        User.isSingleton = false
    }
}
