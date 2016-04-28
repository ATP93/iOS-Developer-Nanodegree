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
    case PostLocation = "PostStudentLocation"
}

//------------------------------------------------
// MARK: - MapViewController: UIViewController
//------------------------------------------------

class MapViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    private var locations: [StudentLocation] = []
    
    private var shouldUpdateStudentLocation = false
    
    //------------------------------------------------
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStudentLocations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.PostLocation.rawValue {
            let postLocationViewController = segue.destinationViewController as! PostLocationViewController
            
            if shouldUpdateStudentLocation {
                let location = sender as! StudentLocation
                postLocationViewController.locationToUpdate = location
            }
            
            shouldUpdateStudentLocation = false
        }
    }
    
    //------------------------------------------------
    // MARK: Network
    //------------------------------------------------
    
    func fetchStudentLocations() {
        for anAnnotation in mapView.annotations {
            mapView.removeAnnotation(anAnnotation)
        }
        
        showNetworkActivityIndicator()
        ParseApiClient.sharedInstance.getStudentLocationsWithCompletionHandler { (locations, error) in
            performOnMain {
                hideNetworkActivityIndicator()
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let locations = locations {
                        print("Successfully fetched \(locations.count) users locations.")
                        self.locations = locations
                        self.mapView.addAnnotations(self.locations)
                    }
                }
            }
        }
    }
    
    //------------------------------------------------
    // MARK: Actions
    //------------------------------------------------
    
    @IBAction func syncronizeDidPressed(sender: AnyObject) {
        fetchStudentLocations()
    }
    
    @IBAction func postLocationDidPressed(sender: AnyObject) {
        showNetworkActivityIndicator()
        let userId = UdacityApiClient.sharedInstance.userSession.userId!
        ParseApiClient.sharedInstance.getStudentLocationWithId(userId) { (location, error) in
            performOnMain {
                hideNetworkActivityIndicator()
                
                guard error == nil else {
                    self.presentAlertWithTitle("An error occured", message: error!.localizedDescription)
                    return
                }
                
                // Overwrite existing location or post a new one?
                guard let location = location else {
                    self.shouldUpdateStudentLocation = false
                    self.performSegueWithIdentifier(SegueIdentifier.PostLocation.rawValue, sender: self)
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
                        self.performSegueWithIdentifier(SegueIdentifier.PostLocation.rawValue,
                            sender: location)
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
        if let annotation = annotation as? StudentLocation {
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
            if annotation.uniqueKey == UdacityApiClient.sharedInstance.userSession.userId! {
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
            if let location = view.annotation as? StudentLocation {
                let alert = (location as Alertable).alert()
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
}
