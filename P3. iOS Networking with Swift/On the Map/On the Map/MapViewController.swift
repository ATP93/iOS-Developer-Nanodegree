//
//  FirstViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import MapKit

//------------------------------------------------
// MARK: Types
//------------------------------------------------

private enum SegueIdentifier: String {
    case ManageLocation = "ManageStudentLocation"
}

//------------------------------------------------
// MARK: - MapViewController: UIViewController
//------------------------------------------------

class MapViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    private let dataCentral = DataCentral.sharedInstance
    private let udacityApiClient = UdacityApiClient.sharedInstance
    private let parseApiClient = ParseApiClient.sharedInstance
    
    private var shouldUpdateStudentLocation = false
    private var locationToUpdate: StudentLocation?
    
    //------------------------------------------------
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToNotification(DataCentralDidUpdateStudentLocations, selector: #selector(MapViewController.refreshAnnotations))
        subscribeToNotification(DataCentralDidFailedUpdateStudentLocations, selector: #selector(MapViewController.handleFailedLocationsUpdate(_:)))
        
        dataCentral.fetchStudentLocations()
    }
    
    deinit {
        unsubscribeFromAllNotifications()
    }
    
    //------------------------------------------------
    // MARK: Navigation
    //------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ManageLocation.rawValue {
            let manageLocationViewController = segue.destinationViewController as! ManageLocationViewController
            manageLocationViewController.parseApiClient = parseApiClient
            manageLocationViewController.udacityApiClient = udacityApiClient
            
            if shouldUpdateStudentLocation {
                manageLocationViewController.locationToUpdate = locationToUpdate!
            }
            
            shouldUpdateStudentLocation = false
            locationToUpdate = nil
        }
    }
    
    //------------------------------------------------
    // MARK: Network
    //------------------------------------------------
    
    func refreshAnnotations() {
        for anAnnotation in mapView.annotations {
            mapView.removeAnnotation(anAnnotation)
        }
        
        let annotations = dataCentral.studentLocations.flatMap { StudentLocationAnnotation(location: $0) }
        self.mapView.addAnnotations(annotations)
    }
    
    func handleFailedLocationsUpdate(notification: NSNotification) {
        // Present alert view controller if view is visible
        guard isViewLoaded() && view.window != nil else {
            return
        }
        
        guard let error = notification.userInfo?[DataCentralErrorNotificationKey] as? NSError else {
            return
        }
        
        presentAlertWithTitle("Failed to update", message: "\(error.localizedDescription) Please try again later.")
    }
    
    //------------------------------------------------
    // MARK: Actions
    //------------------------------------------------
    
    @IBAction func syncronizeDidPressed(sender: AnyObject) {
        dataCentral.fetchStudentLocations()
    }
    
    @IBAction func postLocationDidPressed(sender: AnyObject) {
        showNetworkActivityIndicator()
        parseApiClient.studentLocationWithId(udacityApiClient.userSession.userId!) { (location, error) in
            performOnMain {
                hideNetworkActivityIndicator()
                
                guard error == nil else {
                    self.presentAlertWithTitle("An error occured", message: error!.localizedDescription)
                    return
                }
                
                // Overwrite existing location or post a new one?
                guard let location = location else {
                    self.shouldUpdateStudentLocation = false
                    self.performSegueWithIdentifier(SegueIdentifier.ManageLocation.rawValue, sender: self)
                    return
                }
                
                let title = NSLocalizedString("Location already exist",
                    comment: "Overwrite location alert title")
                let message = NSLocalizedString("You have already posted a location. Would you like to overwrite your current location?",
                    comment: "Overwrite location alert message")
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Cancel", comment: "Cancel"),
                    style: .Cancel,
                    handler: { action in
                        self.shouldUpdateStudentLocation = false
                }))
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Overwrite", comment: "Overwrite"),
                    style: .Default,
                    handler: { action in
                        self.shouldUpdateStudentLocation = true
                        self.locationToUpdate = location
                        self.performSegueWithIdentifier(SegueIdentifier.ManageLocation.rawValue,
                            sender: self)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
}

//----------------------------------------------
// MARK: - MapViewController (UI Functions)
//----------------------------------------------

extension MapViewController {
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//----------------------------------------------
// MARK: - MapViewController: MKMapViewDelegate
//----------------------------------------------

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? StudentLocationAnnotation {
            let view: MKPinAnnotationView
            
            if let dequeueView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView {
                dequeueView.annotation = annotation
                view = dequeueView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view.canShowCallout = true
                view.animatesDrop = false
                view.calloutOffset = CGPoint(x: -5.0, y: 5.0)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            
            // Is is current user annotation.
            if annotation.studentLocation.uniqueKey == UdacityApiClient.sharedInstance.userSession.userId! {
                mapView.setCenterCoordinate(annotation.studentLocation.location.coordinate, animated: true)
                view.pinTintColor = MKPinAnnotationView.greenPinColor()
            } else {
                view.pinTintColor = MKPinAnnotationView.redPinColor()
            }
            
            return view
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let location = view.annotation as? StudentLocationAnnotation {
                let alert = (location as Alertable).alert()
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
}

//--------------------------------------------
// MARK: - MapViewController (Notifications) -
//--------------------------------------------

extension MapViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
