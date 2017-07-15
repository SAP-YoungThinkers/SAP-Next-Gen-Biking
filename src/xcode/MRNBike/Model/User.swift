import Foundation

class User {
    
    var surname: String?
    var firstName: String?
    var userWeight: Int?
    var userWheelSize: Int?
    var shareInfo: Bool?
    var profilePicture : Data? // as JPEG data stream of UIImage
    //private var accountPicturePath: String? = nil
    
    private static var isSingleton: Bool = false
    private static var singletonUser: User? = nil
    
    private init(userData: [String: AnyObject]?) {
        print("user init")
        print(userData as Any)
        
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
                if let wheel = user["wheelSize"] as? Int {
                    self.userWheelSize = wheel
                }
                if let allow = user["allowShare"] as? Int {
                    if allow == 1 {
                        self.shareInfo = true
                    } else {
                        self.shareInfo = false
                    }
                }
                User.isSingleton = true
            }
        }
    }
    
    static func createSingletonUser(userData: [String: AnyObject]?) {
        if User.isSingleton != true {
            print(userData as Any)
            let user = User(userData: userData)
            User.singletonUser = user
        }
    }
    
    static func getUser() -> User {
        return singletonUser!
    }
    
    static func deleteSingleton() {
        User.singletonUser = nil
    }
    
}
