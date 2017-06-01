

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

}
