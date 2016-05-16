//
//  LocationUtils.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 16/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

//-------------------------------------------------
// MARK: - UUIDUtils
//-------------------------------------------------

class LocationUtils {
    
    private init() {
    }
    
    //-------------------------------------------------
    // MARK: Static Functions
    //-------------------------------------------------
    
    class func locationFromCoordinate2D(coordinate: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
}