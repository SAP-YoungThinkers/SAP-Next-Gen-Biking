

import Foundation

class User : NSObject {
    
    var accountName: String!
    var accountPassword: String? = nil
    var accountSurname: String? = nil
    var accountFirstName: String? = nil
    var accountUserWeight: Float? = nil
    var accountUserWheelSize: Float? = nil
    var accountShareInfo: Bool? = true
    var accountProfilePicture : Data? = nil // as JPEG data stream of UIImage
    //var accountPicturePath: String? = nil

    static func getUser(mail: String) {
        StorageHelper.dpqueue.async {
            let urlEnding = "user/readUser.xsjs?email=" + mail
            let returnObj = StorageHelper.prepareRequest(scriptName: urlEnding)
            
            // TODO: User as a Singleton and set properties
            // TODO: Get back to main queue -> avoid inconsistencies
            let defaults = UserDefaults.standard
            if let surname = returnObj["lastname"] as? String {
                defaults.set(surname, forKey: StorageKeys.nameKey)
            }
            if let firstname = returnObj["firstname"] as? String {
                defaults.set(firstname, forKey: StorageKeys.firstnameKey)
            }
            if let wheel = returnObj["wheelSize"] as? Int {
                defaults.set(wheel, forKey: StorageKeys.wheelKey)
            }
            if let weight = returnObj["weight"] as? Int {
                defaults.set(weight, forKey: StorageKeys.weightKey)
            }
            if let allow = returnObj["allowShare"] as? NSNumber{
                defaults.set(Bool(allow), forKey: StorageKeys.shareKey)
            }
            
            // TODO: load image from backend
        }
    }
}
