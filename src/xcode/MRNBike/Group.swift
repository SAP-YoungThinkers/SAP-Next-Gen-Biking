import UIKit

class Group: NSObject {
    //MARK: Properties
    
    var name: String
    var time: String
    
    //MARK: Initialization
    
    init?(name: String, time: String) {
        // Initialize stored properties.
        self.name = name
        self.time = time
    }
}
