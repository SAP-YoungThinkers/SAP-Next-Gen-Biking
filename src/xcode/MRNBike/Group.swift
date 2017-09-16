import UIKit

class Group: NSObject {
    //MARK: Properties
    
    var id = 0
    var name = ""
    var datum = ""
    var startLocation = ""
    var destination = ""
    var text = ""
    var owner = ""
    var privateGroup = 0
    var members = [GroupMember]()
    
    init?(id: Int, name: String, datum: String, startLocation: String, destination: String, text: String, owner: String, privateGroup: Int, members: [GroupMember]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.datum = datum
        self.startLocation = startLocation
        self.destination = destination
        self.text = text
        self.owner = owner
        self.privateGroup = privateGroup
        self.members = members
    }
}
