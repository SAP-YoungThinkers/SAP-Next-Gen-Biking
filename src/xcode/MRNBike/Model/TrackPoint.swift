
import UIKit
import MapKit


class TrackPoint: NSObject, NSCoding {
    
    //MARK: Properties
    var latitude : Double
    var longitude : Double
    var timestamp: Int64
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tp")
    // MARK: Types
    struct PropertyKey {
        static let latKey = "lat"
        static let longKey = "long"
        static let timeKey = "timestamp"
    }
    
    init(point: CLLocationCoordinate2D, timestamp: Int64) {
        self.latitude = point.latitude
        self.longitude = point.longitude
        self.timestamp = timestamp
        
        super.init()
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: PropertyKey.latKey)
        aCoder.encode(longitude, forKey: PropertyKey.longKey)
        aCoder.encode(timestamp, forKey: PropertyKey.timeKey)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeDouble(forKey: PropertyKey.latKey)
        self.longitude = aDecoder.decodeDouble(forKey: PropertyKey.longKey)
        self.timestamp = aDecoder.decodeInt64(forKey: PropertyKey.timeKey)
    }
    
    func dictionary() -> [String: Any] {
        return [
            PropertyKey.latKey: self.latitude,
            PropertyKey.longKey: self.longitude,
            PropertyKey.timeKey: self.timestamp
        ]
    }
}
