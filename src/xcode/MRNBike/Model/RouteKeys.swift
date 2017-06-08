

import UIKit

class RouteKeys: NSObject, NSCoding {
    
    //MARK: Properties
    var keys: [Int]
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("keys")
    // MARK: Types
    struct PropertyKey {
        static let Key = "keys"
    }
    
    init(keys: [Int]) {
        self.keys = keys
        
        super.init()
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(keys, forKey: PropertyKey.Key)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let loadedKeys = aDecoder.decodeObject(forKey: PropertyKey.Key) as? [Int] else {
            self.keys = [Int]()
            return
        }
        
        self.keys = loadedKeys
    }
}
