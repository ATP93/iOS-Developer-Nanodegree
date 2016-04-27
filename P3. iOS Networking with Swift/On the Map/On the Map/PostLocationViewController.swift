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
// MARK: - PostLocationViewController: UIViewController
//------------------------------------------------------

class PostLocationViewController: UIViewController {
    
    //--------------------------------------------------
    // MARK: Properties
    //--------------------------------------------------
    
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
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(PostLocationViewController.keyboardWillShow(_:)))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(PostLocationViewController.keyboardWillHide(_:)))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(PostLocationViewController.keyboardDidShow(_:)))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(PostLocationViewController.keyboardDidHide(_:)))
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
        
        geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
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
    
    private func displayAlert(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//---------------------------------------------------
// MARK: - PostLocationViewController (Configure UI)
//---------------------------------------------------

extension PostLocationViewController {
    
    private func configureUI() {
        configureTextField(locationTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(red:0.59, green:0.68, blue:0.82, alpha:1)])
        textField.tintColor = UIColor.whiteColor()
        textField.delegate = self
    }
    
}

//---------------------------------------------------------
// MARK: - PostLocationViewController: UITextFieldDelegate
//---------------------------------------------------------

extension PostLocationViewController: UITextFieldDelegate {
    
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
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
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
// MARK: - PostLocationViewController: (Notifications)
//---------------------------------------------------------

extension PostLocationViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

//---------------------------------------------------------
// MARK: - PostLocationViewController (SubmitLocationView)
//---------------------------------------------------------

extension PostLocationViewController {
    
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

//----------------------------------------------------------------
// MARK: - PostLocationViewController: SubmitLocationViewDelegate
//----------------------------------------------------------------

extension PostLocationViewController: SubmitLocationViewDelegate {
    
    func submitLocationViewDidCancel(view: SubmitLocationView) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submitLocationViewDidSubmitLocation(view: SubmitLocationView, location: CLLocation, withLinkToShare link: String) {
        view.activityIndicator.startAnimating()
        
        let udacity = UdacityApiClient.sharedInstance
        udacity.getPublicUserData(udacity.userID!) { (user, error) in
            func showError(error: NSError) {
                view.activityIndicator.stopAnimating()
                self.displayAlert(title: "Failed to post location", message: error.localizedDescription)
            }
            
            if let error = error {
                showError(error)
            } else if let user = user {
                ParseApiClient.sharedInstance.postStudentLocation(student: user, placemark: self.placemark!, mediaURL: link, completionHandler: { (success, error) in
                    view.activityIndicator.stopAnimating()
                    
                    if success {
                        let alert = UIAlertController(title: "Success", message: "Your location has been successfully posted!", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        showError(error!)
                    }
                })
            } else {
                view.activityIndicator.stopAnimating()
                
                let userInfo = [NSLocalizedDescriptionKey : "Unexpected error occured"]
                showError(NSError(domain: "com.ivanmagda.On-the-Map.parse.submitStudentLocation", code: 21, userInfo: userInfo))
            }
        }
    }
    
}
