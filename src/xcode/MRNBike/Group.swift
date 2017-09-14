import UIKit

class Group: NSObject {
    //MARK: Properties
    
    var id: Int
    var name: String
    var datum: String
    var startLocation: String
    var destination: String
    var text: String
    var owner: String
    var privateGroup: Int
    
    //MARK: Initialization
    
    init?(id: Int, name: String, datum: String, startLocation: String, destination: String, text: String, owner: String, privateGroup: Int) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.datum = datum
        self.startLocation = startLocation
        self.destination = destination
        self.text = text
        self.owner = owner
        self.privateGroup = privateGroup
    }
}
