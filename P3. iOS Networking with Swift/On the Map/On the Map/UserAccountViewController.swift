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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutBarButtonItem: UIBarButtonItem!
    
    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiClient = UdacityApiClient.sharedInstance
        apiClient.getPublicUserData(apiClient.userSession.userId!) { (user, error) in
            performOnMain {
                if let error = error {
                    print("Failed to get public user data. Error: \(error.localizedDescription)")
                } else {
                    if let user = user {
                        print("Fetched user: \(user)")
                        self.user = user
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        logOutBarButtonItem.enabled = UdacityApiClient.sharedInstance.userSession.isLoggedIn
    }
    
    //--------------------------------------------
    // MARK: Actions
    //--------------------------------------------
    
    @IBAction func logoutDidPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Are you sure?", message: "You want to exit your account. Press Ok if you want it.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            UdacityApiClient.sharedInstance.logOut { [weak self] (success, error) in
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

//------------------------------------------------------
// MARK: UserAccountViewController: UITableViewDataSource
//------------------------------------------------------

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
            cell.rightDetailLabel.text = user?.firstName ?? undefined
        case 1:
            cell.leftTitleLabel.text = "Last name"
            cell.rightDetailLabel.text = user?.lastName ?? undefined
        case 2:
            cell.leftTitleLabel.text = "Email"
            cell.rightDetailLabel.text = user?.email ?? undefined
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
