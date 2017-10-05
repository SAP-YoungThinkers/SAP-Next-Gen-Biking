import Foundation

class User {
    
    var surname: String?
    var firstName: String?
    var userWeight: Int?
    var userWheelSize: Int? // 10 times actual value
    var shareInfo: Int?
    var profilePicture : Data? // as JPEG data stream of UIImage
    //private var accountPicturePath: String? = nil
    
    var wheelRotation: Int?
    var burgersBurned: Double?
    var distanceMade: Double?
    var co2Type : Double?
    
    private static var isSingleton: Bool = false
    private static var singletonUser: User? = nil
    
    public struct co2ComparedObject {
        static let car = 0.133
        static let bus = 0.069
        static let train = 0.065
    }
    
    var friendList = [Friend]()
    
    /*
     CO2 values from http://www.co2nnect.org/help_sheets/?op_id=602&opt_id=98
     values mean: only DIRECT emissions, without fuel / food / production
     in KILOGRAMMS PER KILOMETER!
    */
    
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
                    // 10 times actual value
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
                if let allow = user["allowShare"] as? Int {
                    self.shareInfo = allow
                }
                if let image = user["image"] as? String {
                    self.profilePicture = Data(base64Encoded: image)
                }
                
                User.isSingleton = true

                if let co2Emissions = user["co2Type"] as? String {
                    switch co2Emissions {
                    case "car":
                        self.co2Type = co2ComparedObject.car
                    case "bus":
                        self.co2Type = co2ComparedObject.bus
                    case "train":
                        self.co2Type = co2ComparedObject.train
                    default:
                        self.co2Type = co2ComparedObject.car
                    }
                }
                else {
                    self.co2Type = co2ComparedObject.car
                }
            }
        }
    }
    
    static func createSingletonUser(userData: [String: AnyObject]?) {
        if User.isSingleton != true {
            let user = User(userData: userData)
            User.singletonUser = user
            // now logged in!
            KeychainService.saveLoginStatus(token: "true")
        }
    }
    
    static func getUser() -> User {
        return singletonUser!
    }
    
    static func deleteSingleton() {
        User.isSingleton = false
    }
}
