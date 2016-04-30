//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import FBSDKLoginKit

//-------------------------------------------
// MARK: Types
//-------------------------------------------

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
    @IBOutlet weak var loginWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //-------------------------------------------
    // MARK: - View Life Cycle
    //-------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginWithFacebookButton.delegate = self
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(LoginViewController.keyboardWillShow(_:)))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(LoginViewController.keyboardWillHide(_:)))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(LoginViewController.keyboardDidShow(_:)))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(LoginViewController.keyboardDidHide(_:)))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if UdacityApiClient.sharedInstance.userSession.isLoggedIn {
            completeLogin()
        } else if let accessToken = FBSDKAccessToken.currentAccessToken() {
            print("Facebook access token: \(accessToken.tokenString)")
            facebookLoginWithToken(accessToken)
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
            activityIndicator.startAnimating()
            showNetworkActivityIndicator()
            
            UdacityApiClient.sharedInstance.authenticateWithUsername(username, password: password) { (success, error) in
                performOnMain {
                    self.activityIndicator.stopAnimating()
                    hideNetworkActivityIndicator()
                    
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
    
    private func facebookLoginWithToken(accessToken: FBSDKAccessToken) {
        userDidTapView(self)
        setUIEnabled(false)
        activityIndicator.startAnimating()
        showNetworkActivityIndicator()
        
        UdacityApiClient.sharedInstance.authenticateWithFacebookByAccessToken(accessToken, completionHandler: { (success, error) in
            performOnMain {
                self.activityIndicator.stopAnimating()
                hideNetworkActivityIndicator()
                
                if success {
                    self.completeLogin()
                } else {
                    self.setUIEnabled(true)
                    self.displayAlertWithTitle("Failed to login with Facebook",
                        message: error!.localizedDescription)
                }
            }
        })
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
        
        loginWithFacebookButton.titleLabel?.font = UIFont.systemFontOfSize(19.0)
        loginWithFacebookButton.layer.masksToBounds = true
        loginWithFacebookButton.layer.cornerRadius = 4.0
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.delegate = self
    }
    
}

//--------------------------------------------------------
// MARK: - LoginViewController: FBSDKLoginButtonDelegate -
//--------------------------------------------------------

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else {
            displayAlertWithTitle("Error", message: error.localizedDescription)
            return
        }
        
        guard !result.isCancelled else {
            return
        }
        
        facebookLoginWithToken(FBSDKAccessToken.currentAccessToken())
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
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
            view.frame.origin.y = (keyboardHeight(notification) * -1) / 2.0
            udacityLogoImageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0.0
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
