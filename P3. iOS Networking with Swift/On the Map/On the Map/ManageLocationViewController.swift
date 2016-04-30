//
//  PostLocationViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 22.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import MapKit

//------------------------------------------------------
// MARK: - ManageLocationViewController: UIViewController
//------------------------------------------------------

class ManageLocationViewController: UIViewController {
    
    //--------------------------------------------------
    // MARK: Properties
    //--------------------------------------------------
    
    var udacityApiClient: UdacityApiClient!
    var parseApiClient: ParseApiClient!
    
    var locationToUpdate: StudentLocation?
    
    var keyboardOnScreen = false
    
    private var geocoder = CLGeocoder()
    private var placemark: CLPlacemark? = nil
    private var submitLocationView: SubmitLocationView?
    
    //--------------------------------------------------
    // MARK: Outlets
    //--------------------------------------------------
    
    @IBOutlet weak var locationTextField: UITextField!
    
    //--------------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(parseApiClient != nil && udacityApiClient != nil)
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromAllNotifications()
        geocoder.cancelGeocode()
    }
    
    //--------------------------------------------------
    // MARK: Actions
    //--------------------------------------------------
    
    @IBAction func userDidTapOnEnterLocationView(sender: AnyObject) {
        locationTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelDidPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMapDidPressed(sender: AnyObject) {
        userDidTapView(self)
        
        guard let addressString = locationTextField.text where !addressString.isEmpty else {
            print("Empty map string")
            return
        }
        
        showNetworkActivityIndicator()
        geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
            hideNetworkActivityIndicator()
            if let error = error {
                self?.displayAlert(title: "Geocode error", message: error.localizedDescription, actionHandler: nil)
            } else {
                if let placemarks = placemarks {
                    self?.placemark = placemarks[0]
                    self?.displaySubmitLocationView()
                }
            }
        }
    }
    
    //---------------------------------------
    // MARK: Helpers
    //---------------------------------------
    
    private func displayAlert(title title: String, message: String, actionHandler block: (UIAlertAction -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: block))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//----------------------------------------------------
// MARK: - ManageLocationViewController (Configure UI)
//----------------------------------------------------

extension ManageLocationViewController {
    
    private func configureUI() {
        configureTextField(locationTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(red:0.59, green:0.68, blue:0.82, alpha:1)])
        textField.tintColor = UIColor.whiteColor()
        textField.delegate = self
    }
    
}

//-----------------------------------------------------------
// MARK: - ManageLocationViewController: UITextFieldDelegate
//-----------------------------------------------------------

extension ManageLocationViewController: UITextFieldDelegate {
    
    //--------------------------------------------------
    // MARK: UITextFieldDelegate
    //--------------------------------------------------
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //--------------------------------------------------
    // MARK: Show/Hide Keyboard
    //--------------------------------------------------
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y = keyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0.0
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
    }
    
}

//---------------------------------------------------------
// MARK: - ManageLocationViewController: (Notifications)
//---------------------------------------------------------

extension ManageLocationViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func subscribeToKeyboardNotifications() {
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(ManageLocationViewController.keyboardWillShow(_:)))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(ManageLocationViewController.keyboardWillHide(_:)))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(ManageLocationViewController.keyboardDidShow(_:)))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(ManageLocationViewController.keyboardDidHide(_:)))
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func postUpdateLocationNotification() {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(ManageLocationViewControllerDidUpdateLocation, object: nil)
    }
    
    private func postPostLocationNotification() {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(ManageLocationViewControllerDidPostLocation, object: nil)
    }
    
}

//-----------------------------------------------------------
// MARK: - ManageLocationViewController (SubmitLocationView)
//-----------------------------------------------------------

extension ManageLocationViewController {
    
    func displaySubmitLocationView() {
        func showView(submitView: SubmitLocationView) {
            submitView.alpha = 0.0
            view.addSubview(submitView)
            
            UIView.animateWithDuration(0.45, delay: 0, options: .CurveEaseInOut, animations: {
                submitView.alpha = 1.0
                }, completion: nil)
        }
        
        unsubscribeFromAllNotifications()
        
        if let submitLocationView = submitLocationView {
            submitLocationView.placemark = placemark!
            showView(submitLocationView)
        } else {
            submitLocationView = SubmitLocationView.loadFromNib()!
            submitLocationView?.rootViewController = self
            submitLocationView?.delegate = self
            submitLocationView?.placemark = placemark!
            showView(submitLocationView!)
        }
    }
    
    func hideSubmitLocationView() {
        submitLocationView?.removeFromSuperview()
    }
    
}

//------------------------------------------------------------------
// MARK: - ManageLocationViewController: SubmitLocationViewDelegate
//------------------------------------------------------------------

extension ManageLocationViewController: SubmitLocationViewDelegate {
    
    //------------------------------------------------------------
    // MARK: SubmitLocationViewDelegate
    //------------------------------------------------------------
    
    func submitLocationViewDidCancel(view: SubmitLocationView) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submitLocationViewDidSubmitLocation(view: SubmitLocationView, location: CLLocation, withLinkToShare link: String) {
        if let locationToUpdate = locationToUpdate {
            updateLocation(locationToUpdate, location: location, link: link)
        } else {
            postLocation(location, link: link)
        }
    }
    
    //------------------------------------------------------------
    // MARK: Helpers
    //------------------------------------------------------------
    
    private func updateLocation(locationToUpdate: StudentLocation, location: CLLocation, link: String) {
        showNetworkActivityIndicator()
        
        udacityApiClient.getPublicUserData(udacityApiClient.userSession.userId!) { (user, error) in
            func showError(error: NSError) {
                performOnMain {
                    hideNetworkActivityIndicator()
                    self.displayAlert(title: "Failed to overwrite location",
                        message: error.localizedDescription,
                        actionHandler: nil)
                }
            }
            
            guard error == nil else {
                showError(error!)
                return
            }
            
            guard user != nil else {
                hideNetworkActivityIndicator()
                showError(NSError(
                    domain: "com.ivanmagda.On-the-Map.parse.update-student-location",
                    code: 26,
                    userInfo: [NSLocalizedDescriptionKey : "Unexpected error occured"])
                )
                return
            }
            
            self.parseApiClient.updateStudentLocation(locationToUpdate, student: user!, placemark: self.placemark!, mediaURL: link, completionHandler: { (success, error) in
                performOnMain {
                    hideNetworkActivityIndicator()
                    if success {
                        self.postUpdateLocationNotification()
                        self.displayAlert(
                            title: "Success",
                            message: "Your location successfully updated!",
                            actionHandler: { action in
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    } else {
                        showError(error!)
                    }
                }
            })
        }
    }
    
    private func postLocation(location: CLLocation, link: String) {
        showNetworkActivityIndicator()
        
        udacityApiClient.getPublicUserData(udacityApiClient.userSession.userId!) { (user, error) in
            func showError(error: NSError) {
                performOnMain {
                    hideNetworkActivityIndicator()
                    self.displayAlert(title: "Failed to post location",
                        message: error.localizedDescription,
                        actionHandler: nil)
                }
            }
            
            guard error == nil else {
                showError(error!)
                return
            }
            
            guard user != nil else {
                hideNetworkActivityIndicator()
                showError(NSError(
                    domain: "com.ivanmagda.On-the-Map.parse.submit-student-location",
                    code: 25,
                    userInfo: [NSLocalizedDescriptionKey : "Unexpected error occured"])
                )
                return
            }
            
            self.parseApiClient.postLocationForStudent(user!, placemark: self.placemark!, mediaURL: link, completionHandler: { (success, error) in
                performOnMain {
                    hideNetworkActivityIndicator()
                    if success {
                        self.postPostLocationNotification()
                        self.displayAlert(
                            title: "Success",
                            message: "Your location successfully posted!",
                            actionHandler: { action in
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    } else {
                        showError(error!)
                    }
                }
            })
        }
    }
    
}
