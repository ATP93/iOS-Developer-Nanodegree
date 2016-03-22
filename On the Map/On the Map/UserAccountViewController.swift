//
//  UserAccountViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-----------------------------------------------------
// MARK: - UserAccountViewController: UIViewController
//-----------------------------------------------------

class UserAccountViewController: UIViewController {
    
    //--------------------------------------------
    // MARK: Properties
    //--------------------------------------------
    
    var user: User? = nil
 
    //--------------------------------------------
    // MARK: Outlets
    //--------------------------------------------
    
    @IBOutlet weak var logOutBarButtonItem: UIBarButtonItem!
    
    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiClient = UdacityApiClient.sharedInstance
        apiClient.getPublicUserData(apiClient.userID!) { (user, error) in
            performOnMain {
                if let error = error {
                    print("Failed to get public user data. Error: \(error.localizedDescription)")
                } else {
                    if let user = user {
                        print("Fetched user: \(user)")
                        self.user = user
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        logOutBarButtonItem.enabled = UdacityApiClient.sharedInstance.isUserLoggedIn
    }
    
    //--------------------------------------------
    // MARK: Actions
    //--------------------------------------------
    
    @IBAction func logoutDidPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Are you sure?", message: "You want to exit your account. Press Ok if you want it.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            UdacityApiClient.sharedInstance.logOutWithCompletionHandler { [weak self] (success, error) in
                performOnMain {
                    if success {
                        self?.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self?.displayAlertWithTitle("Failed to log out", message: error!.localizedDescription)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //--------------------------------------------
    // MARK: Helpers
    //--------------------------------------------
    
    private func displayAlertWithTitle(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
