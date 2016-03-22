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
    
    private var studentLocations = [StudentLocation]()
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
        
        fetchLocations()
    }
    
    //--------------------------------------------
    // MARK: Network
    //--------------------------------------------
    
    func fetchLocations() {
        ParseApiClient.sharedInstance.getStudentLocationsWithCompletionHandler { [weak self] (locations, error) in
            performOnMain {
                self?.refreshControl.endRefreshing()
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let locations = locations {
                        print("Successfully fetched \(locations.count) users locations.")
                        self?.studentLocations = locations
                        self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                    }
                }
            }
        }
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
        return studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)!
        cell.textLabel?.text = ""
        
        guard indexPath.row < studentLocations.count else {
            return cell
        }
        
        let location = studentLocations[indexPath.row]
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        
        return cell
    }
    
}

extension LocationsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        studentLocations[indexPath.row].openMediaURLInSafari()
    }
    
}

