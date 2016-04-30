//
//  SubmitLocationView.swift
//  On the Map
//
//  Created by Ivan Magda on 22.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import MapKit

//-------------------------------------------
// MARK: SubmitLocationViewDelegate
//-------------------------------------------

protocol SubmitLocationViewDelegate {
    func submitLocationViewDidCancel(view: SubmitLocationView)
    func submitLocationViewDidSubmitLocation(view: SubmitLocationView, location: CLLocation, withLinkToShare link: String)
}

//-------------------------------------------
// MARK: - SubmitLocationView: UIView
//-------------------------------------------

class SubmitLocationView: UIView {
    
    //---------------------------------------
    // MARK: Properties
    //---------------------------------------
    
    var delegate: SubmitLocationViewDelegate? = nil
    var placemark: CLPlacemark!
    
    weak var rootViewController: UIViewController?
    
    //---------------------------------------
    // MARK: Outlets
    //---------------------------------------
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var linkShareTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: BorderedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //---------------------------------------
    // MARK: View Life Cycle
    //---------------------------------------
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        assert(placemark != nil, "Placemark must exist")
        
        if let newSuperview = newSuperview {
            frame = newSuperview.frame
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureUI()
    }
    
    //---------------------------------------
    // MARK: Actions
    //---------------------------------------
    
    @IBAction func cancelDidPressed(sender: AnyObject) {
        guard let delegate = delegate else {
            rootViewController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        delegate.submitLocationViewDidCancel(self)
    }
    
    @IBAction func submitDidPressed(sender: AnyObject) {
        guard let delegate = delegate else {
            return
        }
        
        guard let location = placemark.location else {
            displayAlert(title: "An error occured", message: "Try to search for a location again")
            return
        }
        
        guard let link = linkShareTextField.text where !link.isEmpty else {
            displayAlert(title: "", message: "Link to share is empty")
            return
        }
        
        delegate.submitLocationViewDidSubmitLocation(self, location: location, withLinkToShare: link)
    }
    
    //---------------------------------------
    // MARK: Helpers
    //---------------------------------------
    
    private func displayAlert(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
}

//-------------------------------------------
// MARK: - SubmitLocationView (Configure UI)
//-------------------------------------------

extension SubmitLocationView {
    
    private func configureUI() {
        configureTextField(linkShareTextField)
        configureMapView()
    }
    
    private func configureTextField(textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(red:0.63, green:0.74, blue:0.85, alpha:1.00)])
        textField.tintColor = UIColor.whiteColor()
        textField.delegate = self
    }
    
    private func configureMapView() {
        let coordinate = placemark.location!.coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = placemark.name
        mapView.addAnnotation(annotation)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
    }
    
}

//------------------------------------------------------
// MARK: - SubmitLocationView: UITextFieldDelegate
//------------------------------------------------------

extension SubmitLocationView: UITextFieldDelegate {
    
    //--------------------------------------------------
    // MARK: UITextFieldDelegate
    //--------------------------------------------------
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//------------------------------------------------------
// MARK: - SubmitLocationView: (Load from Nib)
//------------------------------------------------------

extension SubmitLocationView {
    
    class func loadFromNib() -> SubmitLocationView? {
        return UINib(nibName: "SubmitLocationView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? SubmitLocationView
    }
    
}

//----------------------------------------------
// MARK: - SubmitLocationView: MKMapViewDelegate
//----------------------------------------------

extension SubmitLocationView: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let view: MKPinAnnotationView
        
        if let dequeueView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView {
            dequeueView.annotation = annotation
            view = dequeueView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view.canShowCallout = true
            view.animatesDrop = true
            view.calloutOffset = CGPoint(x: -5.0, y: 5.0)
            view.pinTintColor = MKPinAnnotationView.redPinColor()
        }
        
        return view
    }
    
}
