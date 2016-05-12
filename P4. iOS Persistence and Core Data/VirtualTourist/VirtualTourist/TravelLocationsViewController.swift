//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 11/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import MapKit
import Darwin.C

//---------------------------------------------------------
// MARK: - TravelLocationsViewController: UIViewController
//---------------------------------------------------------

class TravelLocationsViewController: UIViewController {
    
    //-----------------------------------------------------
    // MARK: - Properties
    //-----------------------------------------------------
    
    private static let locationUpdateTimeInterval = 3.0
    
    // MARK: Public
    var coreDataStackManager: CoreDataStackManager!
    
    // MARK: Private
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    private var userLocation: CLLocation?
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //-----------------------------------------------------
    // MARK: View Life Cycle
    //-----------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(coreDataStackManager != nil)
        
        checkLocationAuthorizationStatus()
    }
    //-----------------------------------------------------
    // MARK: Helpers
    //-----------------------------------------------------
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
}

//------------------------------------------------------------------
// MARK: - TravelLocationsViewController: CLLocationManagerDelegate
//------------------------------------------------------------------

extension TravelLocationsViewController: CLLocationManagerDelegate {
    
    //--------------------------------------------------------------
    // MARK: CLLocationManagerDelegate
    //--------------------------------------------------------------
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // GUARD: Did location is currently unknown?
        guard error.code != CLError.LocationUnknown.rawValue else {
            return
        }
        print("Did fail updating location with error: \(error.localizedDescription)")
        stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        print("\(#function): \(newLocation)")
        
        // Ignore these locations if they are too old.
        guard newLocation.timestamp.timeIntervalSinceNow > -1.0 else {
            return
        }
        
        // If measurements are invalid ignore them.
        guard newLocation.horizontalAccuracy > 0 else {
            return
        }
        
        // Calculates the distance between the new reading and the previous reading.
        var distance: CLLocationDistance = DBL_MAX
        guard userLocation != nil else {
            userLocation = newLocation
            updateMapRegionWithLocation(newLocation)
            return
        }
        distance = newLocation.distanceFromLocation(userLocation!)
        
        // If the new reading coordinates is more useful than the previous one.
        // Larger accuracy value actually means less accurate.
        if userLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            userLocation = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("Done updating user location. Desired accuracy is reached.")
                stopUpdatingLocation()
            }
            
            updateMapRegionWithLocation(newLocation)
            
            // If the coordinate from this reading is not significantly different from
            // the previous reading and it has been more than 5 seconds since you’ve
            // received that original reading, then it’s a good point to stop.
        }
        
        if distance < 10.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(userLocation!.timestamp)
            if timeInterval > TravelLocationsViewController.locationUpdateTimeInterval {
                print("Force done updating user location.")
                stopUpdatingLocation()
            }
        }
    }
    
    //--------------------------------------------------------------
    // MARK: Helpers
    //--------------------------------------------------------------
    
    private func updateMapRegionWithLocation(location: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
    
}
