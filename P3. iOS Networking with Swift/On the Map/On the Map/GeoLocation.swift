//
//  Geolocation.swift
//  On the Map
//
//  Created by Ivan Magda on 22.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import MapKit

struct GeoLocation {
    var latitude: Double
    var longitude: Double
}

extension GeoLocation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var mapPoint: MKMapPoint {
        return MKMapPointForCoordinate(coordinate)
    }
    
}
