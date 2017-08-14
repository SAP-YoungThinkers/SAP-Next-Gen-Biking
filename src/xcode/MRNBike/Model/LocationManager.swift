import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D)
}

class LocationManager: NSObject {

    var locationManager = CLLocationManager()
    var config: Configurator
    
    var delegate: LocationManagerDelegate?
    
    var center: CLLocationCoordinate2D {
        let location = locationManager.location
        return CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    }
    
    override init() {
        config = Configurator()
        super.init()
        
        locationManager.delegate = self
        
        //get authorization
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        //settings
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = config.distanceFilter //treshold for movement
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = config.allowAutoLocationPause
        //pauses only, when the user does not move a significant distance over a period of time
        locationManager.activityType = CLActivityType.automotiveNavigation
        locationManager.disallowDeferredLocationUpdates()

        locationManager.delegate = self
    }
    
    func startTracking() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation() //this one is used in AppDelegate
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            delegate?.didUpdateLocation(coordinate)
        }
    }
    
    // MARK: Print out error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
}
