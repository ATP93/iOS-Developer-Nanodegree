//
//  UserDefaultsUtils.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 12/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import MapKit

//-------------------------------------------------
// MARK: Types
//-------------------------------------------------

private enum UserDefaultsUtilsKey: String {
    case Registed
    case FirstLaunch
    
    case Latitude
    case Longitude
    case LatitudeDelta
    case LongitudeDelta
}

//-------------------------------------------------
// MARK: - UserDefaultsUtils
//-------------------------------------------------

class UserDefaultsUtils {

    //-------------------------------------------------
    // MARK: - Properties
    //-------------------------------------------------
    
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //-------------------------------------------------
    // MARK: - Init
    //-------------------------------------------------
    
    private init() {
    }
    
    //-------------------------------------------------
    // MARK: - Static Functions -
    //-------------------------------------------------
    
    // MARK: Public
    
    class func activate() {
        guard userDefaults.boolForKey(UserDefaultsUtilsKey.Registed.rawValue) == false else {
            return
        }
        
        registerDefaults()
    }
    
    class func synchronize() {
        userDefaults.synchronize()
    }
    
    class func isFirstAppLaunch() -> Bool {
        let launchState = userDefaults.boolForKey(UserDefaultsUtilsKey.FirstLaunch.rawValue)
        if launchState {
            userDefaults.setBool(false, forKey: UserDefaultsUtilsKey.FirstLaunch.rawValue)
        }
        
        return launchState
    }
    
    class func persistMapRegion(region: MKCoordinateRegion) {
        let center = region.center
        let span = region.span
        
        userDefaults.setDouble(center.latitude, forKey: UserDefaultsUtilsKey.Latitude.rawValue)
        userDefaults.setDouble(center.longitude, forKey: UserDefaultsUtilsKey.Longitude.rawValue)
        userDefaults.setDouble(span.latitudeDelta, forKey: UserDefaultsUtilsKey.LatitudeDelta.rawValue)
        userDefaults.setDouble(span.longitudeDelta, forKey: UserDefaultsUtilsKey.LongitudeDelta.rawValue)
        
        userDefaults.synchronize()
    }
    
    class func persistedMapRegion() -> MKCoordinateRegion {
        let latitude = userDefaults.doubleForKey(UserDefaultsUtilsKey.Latitude.rawValue)
        let longitude = userDefaults.doubleForKey(UserDefaultsUtilsKey.Longitude.rawValue)
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let latitudeDelta = userDefaults.doubleForKey(UserDefaultsUtilsKey.LatitudeDelta.rawValue)
        let longitudeDelta = userDefaults.doubleForKey(UserDefaultsUtilsKey.LongitudeDelta.rawValue)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    // MARK: Private
    
    private class func registerDefaults() {
        userDefaults.registerDefaults([UserDefaultsUtilsKey.FirstLaunch.rawValue: true])
    }
    
}
