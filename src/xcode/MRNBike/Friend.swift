import UIKit

class Friend {
    
    //MARK: Properties
    
    var eMail: String
    var firstname: String
    var lastname: String
    var photo: UIImage?
    
    //MARK: Initialization
    
    init?(email: String, firstname: String, lastname: String, photo: UIImage?) {
        // Initialize stored properties.
        self.eMail = email
        self.firstname = firstname
        self.lastname = lastname
        self.photo = photo
    }
}
