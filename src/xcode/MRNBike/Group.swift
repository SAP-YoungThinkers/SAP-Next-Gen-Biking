import UIKit

class Group: NSObject {
    //MARK: Properties
    
    var name: String
    var datum: String
    var startLocation: String
    var destination: String
    var text: String
    var owner: String
    var privateGroup: Int
    
    //MARK: Initialization
    
    init?(name: String, datum: String, startLocation: String, destination: String, text: String, owner: String, privateGroup: Int) {
        // Initialize stored properties.
        self.name = name
        self.datum = datum
        self.startLocation = startLocation
        self.destination = destination
        self.text = text
        self.owner = owner
        self.privateGroup = privateGroup
    }
}
