import UIKit

class GroupMember: NSObject {
    //MARK: Properties
    
    var email = ""
    var firstname = ""
    var lastname = ""
    
    init?(email: String, firstname: String, lastname: String) {
        // Initialize stored properties.
        self.email = email
        self.firstname = firstname
        self.lastname = lastname
    }
}
