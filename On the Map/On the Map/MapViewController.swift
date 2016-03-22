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
// MARK: - MapViewController: UIViewController
//------------------------------------------------

class MapViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    private var locations: [StudentLocation] = []
    
    //------------------------------------------------
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocations()
    }
    
    //------------------------------------------------
    // MARK: Network
    //------------------------------------------------
    
    func getLocations() {
        for anAnnotation in mapView.annotations {
            mapView.removeAnnotation(anAnnotation)
        }
        
        ParseApiClient.sharedInstance.getStudentLocationsWithCompletionHandler { (locations, error) in
            performOnMain {
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
        getLocations()
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
            if annotation.uniqueKey == UdacityApiClient.sharedInstance.userID! {
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

