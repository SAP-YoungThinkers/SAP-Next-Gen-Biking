/*
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
 */

import Foundation

class User {
    
    var surname: String?
    var firstName: String?
    var userWeight: Int?
    var userWheelSize: Int?
    var shareInfo: Int?
    //private var accountProfilePicture : Data? = nil // as JPEG data stream of UIImage
    //private var accountPicturePath: String? = nil
    
    private static var isSingleton: Bool?
    private static var singletonUser: User?
    
    private init(userData: [String: AnyObject]) {
        
        if let surname = userData["lastname"] as? String {
            self.surname = surname
        }
        if let firstname = userData["firstname"] as? String {
            self.firstName = firstname
        }
        if let weight = userData["weight"] as? Int {
            self.userWeight = weight
        }
        if let wheel = userData["wheelSize"] as? Int {
            self.userWheelSize = wheel
        }
        
        if let allow = userData["allowShare"] as? Int {
            self.shareInfo = allow
        }
        User.isSingleton = true
        //self.accountProfilePicture =
        
    }
    
    class func createSingletonUser(userData: [String: AnyObject]) {
        if User.isSingleton != true {
            let user = User(userData: userData)
            User.singletonUser = user
        }
    }
    
    static func getUser() -> User {
        return singletonUser!
    }
    
}
