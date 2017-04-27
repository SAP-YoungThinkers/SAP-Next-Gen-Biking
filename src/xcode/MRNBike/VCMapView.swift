//
//  VCMapView.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 27.04.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import MapKit

extension UIViewController {
    
    // gets called for every annotation you add to the map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? RouteReport {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                // are set up to reuse annotation views when some are no longer visible. So the code first checks to see if a reusable annotation view is available before creating a new one
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else {
                // if an annotation view could not be dequeued. It uses the title and subtitle properties of your Artwork class to determine what to show in the callout – the little bubble that pops up when the user taps on the pin.
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
}
