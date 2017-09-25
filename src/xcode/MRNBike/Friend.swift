import UIKit

class Friend {
    
    //MARK: Properties
    
    var email: String
    var firstname: String
    var lastname: String
    var photo: Data? // as JPEG data stream of UIImage
    
    //MARK: Initialization
    
    init?(email: String, firstname: String, lastname: String, photo: Data) {
        // Initialize stored properties.
        self.email = email
        self.firstname = firstname
        self.lastname = lastname
        self.photo = photo
    }
}
