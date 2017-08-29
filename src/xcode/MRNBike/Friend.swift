import UIKit

class Friend {
    
    //MARK: Properties
    
    var firstname: String
    var lastname: String
    var photo: UIImage?
    
    //MARK: Initialization
    
    init?(firstname: String, lastname: String, photo: UIImage?) {
        // Initialize stored properties.
        self.firstname = firstname
        self.lastname = lastname
        self.photo = photo
    }
}
