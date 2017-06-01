

import MapKit

class RouteReport : NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let primaryColor = UIColor(red: (192/255.0), green: (57/255.0), blue: (43/255.0), alpha: 1.0)
    
    init(title: String, message: String, coordinate: CLLocationCoordinate2D) {
        self.subtitle = message
        self.coordinate = coordinate
        self.title = title
        
        super.init()
    }
    
}
