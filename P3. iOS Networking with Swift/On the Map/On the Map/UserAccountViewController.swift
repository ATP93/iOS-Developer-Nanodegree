//
//  UserAccountViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import FBSDKLoginKit

//-----------------------------------------------------
// MARK: - UserAccountViewController: UIViewController
//-----------------------------------------------------

class UserAccountViewController: UIViewController {
    
    //--------------------------------------------
    // MARK: Properties
    //--------------------------------------------
    
    private let dataCentral = DataCentral.sharedInstance
    private let udacityApiClient = UdacityApiClient.sharedInstance
    private let parseApiClient = ParseApiClient.sharedInstance
 
    //--------------------------------------------
    // MARK: Outlets
    //--------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutBarButtonItem: UIBarButtonItem!
    
    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToNotification(DataCentralDidUpdateCurrentUser, selector: #selector(UserAccountViewController.reloadData))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        logOutBarButtonItem.enabled = udacityApiClient.userSession.isLoggedIn
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if dataCentral.currentUser == nil {
            dataCentral.fetchForCurrentUser()
        }
    }
    
    //--------------------------------------------
    // MARK: Helpers
    //--------------------------------------------
    
    func reloadData() {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    //--------------------------------------------
    // MARK: Actions
    //--------------------------------------------
    
    @IBAction func logoutDidPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Are you sure?", message: "You want to exit your account. Press Ok if you want it.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //--------------------------------------------
    // MARK: Logout
    //--------------------------------------------
    
    private func logout() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            facebookLogout()
        } else {
            udacityLogout()
        }
    }
    
    private func facebookLogout() {
        FBSDKLoginManager().logOut()
        UdacityUserSession.logout()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func udacityLogout() {
        showNetworkActivityIndicator()
        UdacityApiClient.sharedInstance.logOut { [weak self] (success, error) in
            performOnMain {
                hideNetworkActivityIndicator()
                if success {
                    self?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self?.presentAlertWithTitle("Failed to log out", message: error!.localizedDescription)
                }
            }
        }
    }
    
}

//----------------------------------------------------------
// MARK: - UserAccountViewController: (UI Functions)
//----------------------------------------------------------

extension UserAccountViewController {
    
    private func presentAlertWithTitle(title: String?, message: String?, actionHandler: (UIAlertAction -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//----------------------------------------------------------
// MARK: - UserAccountViewController: UITableViewDataSource
//----------------------------------------------------------

extension UserAccountViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if UdacityApiClient.sharedInstance.userSession.isLoggedIn {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserTableViewCell
        
        let undefined = "(Undefined)"
        switch indexPath.row {
        case 0:
            cell.leftTitleLabel.text = "First name"
            cell.rightDetailLabel.text = dataCentral.currentUser?.firstName ?? undefined
        case 1:
            cell.leftTitleLabel.text = "Last name"
            cell.rightDetailLabel.text = dataCentral.currentUser?.lastName ?? undefined
        case 2:
            cell.leftTitleLabel.text = "Email"
            cell.rightDetailLabel.text = dataCentral.currentUser?.email ?? undefined
        default:
            print("Unexpected error")
        }
        
        return cell
    }
    
}

//------------------------------------------------------
// MARK: UserAccountViewController: UITableViewDelegate
//------------------------------------------------------

extension UserAccountViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
}

//----------------------------------------------------
// MARK: - UserAccountViewController (Notifications) -
//----------------------------------------------------

extension UserAccountViewController {
    
    func handleFailedCurrentUserUpdate(notification: NSNotification) {
        // Present alert view controller if view is visible
        guard isViewLoaded() && view.window != nil else {
            return
        }
        
        guard let error = notification.userInfo?[DataCentralErrorNotificationKey] as? NSError else {
            return
        }
        
        let alert = UIAlertController(
            title: "Failed to fetch info",
            message: "\(error.localizedDescription) Try again to fetch info?",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { action in
            self.dataCentral.fetchForCurrentUser()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
