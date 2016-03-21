//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

private enum SegueIdentifier: String {
    case DoneWithLogin
}

//-----------------------------------------------
// MARK: - LoginViewController: UIViewController
//-----------------------------------------------

class LoginViewController: UIViewController {
    
    //-------------------------------------------
    // MARK: - Properties
    //-------------------------------------------
    
    var keyboardOnScreen = false
    
    //-------------------------------------------
    // MARK: Outlets
    //-------------------------------------------
    
    @IBOutlet weak var udacityLogoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginWithUdacityButton: BorderedButton!
    @IBOutlet weak var loginWithFacebookButton: BorderedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //-------------------------------------------
    // MARK: - View Life Cycle
    //-------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: Constants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: Constants.Selectors.KeyboardDidHide)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if UdacityApiClient.sharedInstance.isUserLoggedIn {
            completeLogin()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    //-------------------------------------------
    // MARK: - Login
    //-------------------------------------------
    
    @IBAction func loginWithUdacityDidPressed(sender: AnyObject) {
        userDidTapView(self)
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if username.isEmpty || password.isEmpty {
            displayAlertWithTitle(nil, message: "Username or Password Empty")
        } else {
            setUIEnabled(false)
            self.activityIndicator.startAnimating()
            
            UdacityApiClient.sharedInstance.authenticateWithUsername(username, password: password) { (success, error) in
                performOnMain {
                    self.activityIndicator.stopAnimating()
                    
                    if success {
                        self.completeLogin()
                    } else {
                        self.setUIEnabled(true)
                        self.displayAlertWithTitle("Failed to login", message: error!.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func loginWithFacebookDidPressed(sender: AnyObject) {
        userDidTapView(self)
    }
    
    private func displayAlertWithTitle(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func completeLogin() {
        performOnMain {
            self.setUIEnabled(true)
            self.performSegueWithIdentifier(SegueIdentifier.DoneWithLogin.rawValue, sender: self)
            
            self.usernameTextField.text = nil
            self.passwordTextField.text = nil
        }
    }
    
}

//---------------------------------------------
// MARK: - LoginViewController (Configure UI) -
//---------------------------------------------

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginWithUdacityButton.enabled = enabled
        loginWithFacebookButton.enabled = enabled
        
        // Adjust login buttons alpha.
        if enabled {
            loginWithUdacityButton.alpha = 1.0
            loginWithFacebookButton.alpha = 1.0
        } else {
            loginWithUdacityButton.alpha = 0.5
            loginWithFacebookButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.delegate = self
    }
    
}

//---------------------------------------------------
// MARK: - LoginViewController: UITextFieldDelegate -
//---------------------------------------------------

extension LoginViewController: UITextFieldDelegate {
    
    //----------------------------------------------
    // MARK: UITextFieldDelegate
    //----------------------------------------------
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //----------------------------------------------
    // MARK: Show/Hide Keyboard
    //----------------------------------------------
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification) / 2
            udacityLogoImageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification) / 2
            udacityLogoImageView.hidden = false
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
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
}

//----------------------------------------------
// MARK: - LoginViewController (Notifications) -
//----------------------------------------------

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
