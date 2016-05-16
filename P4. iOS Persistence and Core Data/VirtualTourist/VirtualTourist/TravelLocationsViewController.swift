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
    // MARK: - Properties -
    //-----------------------------------------------------
    
    // MARK: Public
    var coreDataStackManager: CoreDataStackManager!
    
    // MARK: Private
    private static let locationUpdateTimeInterval = 5.0
    private static let annotationViewReuseIdentifier = "PinAnnotationView"
    
    private var currentUserLocation: CLLocation?
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    private var didInvokeDidSelectAnnotationView = false
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //-----------------------------------------------------
    // MARK: - View Life Cycle -
    //-----------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(coreDataStackManager != nil)
        
        configureMapView()
    }
    
}

//----------------------------------------------------------
// MARK: - TravelLocationsViewController (MapView Helpers) -
//----------------------------------------------------------

extension TravelLocationsViewController {
    
    // MARK: Public
    
    func pinOnLongPressGesture(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Ended:
            addAnnotationFromTouchPoint(gestureRecognizer.locationInView(mapView))
        default:
            return
        }
    }
    
    func pinOnTapGesture(gestureRecognizer: UIGestureRecognizer) {
        func resetDidInvoke() {
            didInvokeDidSelectAnnotationView = false
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        performAfterOnMain(0.45) {
            guard self.didInvokeDidSelectAnnotationView == false else {
                resetDidInvoke()
                return
            }
            
            self.addAnnotationFromTouchPoint(touchPoint)
            resetDidInvoke()
        }
    }
    
    // MARK: Private
    
    private func addAnnotationFromTouchPoint(point: CGPoint) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateFromPoint(point)
        mapView.addAnnotation(annotation)
    }
    
    private func coordinateFromPoint(point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convertPoint(point, toCoordinateFromView: mapView)
    }
    
    private func configureMapView() {
        mapView.delegate = self
        
        if !UserDefaultsUtils.isFirstAppLaunch() {
            mapView.setRegion(UserDefaultsUtils.persistedMapRegion(), animated: false)
        }
        
        checkLocationAuthorizationStatus()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.pinOnLongPressGesture(_:)))
        lpgr.minimumPressDuration = 0.75
        mapView.addGestureRecognizer(lpgr)
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.pinOnTapGesture(_:)))
        mapView.addGestureRecognizer(tgr)
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            
            // Center map on the current user location, if it first time when app launch.
            if UserDefaultsUtils.isFirstAppLaunch() {
                startUpdatingLocation()
            }
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

//-------------------------------------------------------------------
// MARK: - TravelLocationsViewController: MKMapViewDelegate -
//-------------------------------------------------------------------

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaultsUtils.persistMapRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: TravelLocationsViewController.annotationViewReuseIdentifier)
        annotationView.pinTintColor = MKPinAnnotationView.redPinColor()
        annotationView.animatesDrop = true
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        didInvokeDidSelectAnnotationView = true
        print(#function + "\(view)")
    }
    
}

//-------------------------------------------------------------------
// MARK: - TravelLocationsViewController: CLLocationManagerDelegate -
//-------------------------------------------------------------------

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
        guard currentUserLocation != nil else {
            currentUserLocation = newLocation
            updateMapRegionWithLocation(newLocation)
            return
        }
        distance = newLocation.distanceFromLocation(currentUserLocation!)
        
        // If the new reading coordinates is more useful than the previous one.
        // Larger accuracy value actually means less accurate.
        if currentUserLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            currentUserLocation = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("Done updating user location. Desired accuracy is reached.")
                stopUpdatingLocation()
            }
            
            updateMapRegionWithLocation(newLocation)
        }
        
        // If the coordinate from this reading is not significantly different from
        // the previous reading and it has been more than 5 seconds(see locationUpdateTimeInterval)
        // since you’ve received that original reading, then it’s a good point to stop.
        
        let timeInterval = newLocation.timestamp.timeIntervalSinceDate(currentUserLocation!.timestamp)
        if distance < 10.0 ||
            timeInterval > TravelLocationsViewController.locationUpdateTimeInterval {
            print("Force done updating user location.")
            stopUpdatingLocation()
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
