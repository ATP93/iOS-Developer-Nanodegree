//
//  SecondViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//---------------------------------------------------
// MARK: - LocationsViewController: UIViewController
//---------------------------------------------------

class LocationsViewController: UIViewController {
    
    //--------------------------------------------
    // MARK: Properties
    //--------------------------------------------
    
    private let dataCentral = DataCentral.sharedInstance
    private let udacityApiClient = UdacityApiClient.sharedInstance
    private let parseApiClient = ParseApiClient.sharedInstance
    
    private let cellReuseIdentifier = "StudentLocationCell"
    
    var refreshControl: UIRefreshControl!

    //--------------------------------------------
    // MARK: Outlets
    //--------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    
    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LocationsViewController.fetchLocations), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        subscribeToNotification(DataCentralDidUpdateStudentLocations, selector: #selector(LocationsViewController.reloadData))
        subscribeToNotification(DataCentralDidFailedUpdateStudentLocations, selector: #selector(LocationsViewController.handleFailedLocationsUpdate(_:)))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataCentral.studentLocations.count == 0 {
            dataCentral.fetchStudentLocations()
        }
    }
    
    deinit {
        unsubscribeFromAllNotifications()
    }
    
    //--------------------------------------------
    // MARK: Working with Data
    //--------------------------------------------
    
    func reloadData() {
        refreshControl.endRefreshing()
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    func fetchLocations() {
        dataCentral.fetchStudentLocations()
    }
    
    func handleFailedLocationsUpdate(notification: NSNotification) {
        // Present alert view controller if view is visible
        guard isViewLoaded() && view.window != nil else {
            return
        }
        
        guard let error = notification.userInfo?[DataCentralErrorNotificationKey] as? NSError else {
            return
        }
        
        presentAlertWithTitle("Failed to update", message: "\(error.localizedDescription) Please try again later.")
    }

    //--------------------------------------------
    // MARK: Actions
    //--------------------------------------------

    @IBAction func syncronizeDidPressed(sender: AnyObject) {
        fetchLocations()
    }
    
}

//------------------------------------------------------
// MARK: LocationsViewController: UITableViewDataSource
//------------------------------------------------------

extension LocationsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCentral.studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)!
        cell.textLabel?.text = ""
        
        guard indexPath.row < dataCentral.studentLocations.count else {
            return cell
        }
        
        let location = dataCentral.studentLocations[indexPath.row]
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        
        return cell
    }
    
}

//------------------------------------------------------
// MARK: LocationsViewController: UITableViewDelegate
//------------------------------------------------------

extension LocationsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        StudentLocationAnnotation(location: dataCentral.studentLocations[indexPath.row]).openMediaURLInSafari()
    }
    
}

//------------------------------------------------
// MARK: - LocationsViewController (UI Functions)
//------------------------------------------------

extension LocationsViewController {
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//--------------------------------------------------
// MARK: - LocationsViewController (Notifications) -
//--------------------------------------------------

extension LocationsViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

