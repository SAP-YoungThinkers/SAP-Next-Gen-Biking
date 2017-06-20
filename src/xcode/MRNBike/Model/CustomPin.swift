

import UIKit
import MapKit

class CustomPin : NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }

}
