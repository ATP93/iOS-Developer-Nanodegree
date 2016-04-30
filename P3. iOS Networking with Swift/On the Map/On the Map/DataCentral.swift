//
//  DataCentral.swift
//  On the Map
//
//  Created by Ivan Magda on 30.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//------------------------------------------
// MARK: - DataCentral
//------------------------------------------

class DataCentral: NSObject {
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    var studentLocations = [StudentLocation]()
    var currentUser: User? = nil
    
    //--------------------------------------
    // MARK: Class Variables
    //--------------------------------------
    
    class var sharedInstance: DataCentral {
        struct Static {
            static var instance: DataCentral?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DataCentral()
        }
        
        return Static.instance!
    }
    
    //--------------------------------------
    // MARK: Life Cycle
    //--------------------------------------
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataCentral.fetchStudentLocations), name: ManageLocationViewControllerDidPostLocation, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataCentral.fetchStudentLocations), name: ManageLocationViewControllerDidUpdateLocation, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //--------------------------------------
    // MARK: Private Variables
    //--------------------------------------
    
    private let udacityApiClient = UdacityApiClient.sharedInstance
    private let parseApiClient = ParseApiClient.sharedInstance
    
    //--------------------------------------
    // MARK: Behavior
    //--------------------------------------
    
    func fetchStudentLocations() {
        showNetworkActivityIndicator()
        parseApiClient.getStudentLocationsWithCompletionHandler { (locations, error) in
            performOnMain {
                self.studentLocations = locations ?? []
                
                hideNetworkActivityIndicator()
                
                guard error == nil else {
                    NSNotificationCenter.defaultCenter()
                        .postNotificationName(DataCentralDidFailedUpdateStudentLocations,
                            object: nil,
                            userInfo: [DataCentralErrorNotificationKey: error!])
                    return
                }
                
                print("Successfully fetched \(self.studentLocations.count) users locations.")
                
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(DataCentralDidUpdateStudentLocations, object: nil)
            }
        }
    }
    
    func fetchForCurrentUser() {
        showNetworkActivityIndicator()
        udacityApiClient.getPublicUserData(udacityApiClient.userSession.userId!) { (user, error) in
            performOnMain {
                hideNetworkActivityIndicator()
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                
                if let error = error {
                    print("Failed to get public user data. Error: \(error.localizedDescription)")
                    notificationCenter
                        .postNotificationName(DataCentralDidFailedUpdateCurrentUser,
                            object: nil, userInfo: [DataCentralErrorNotificationKey: error])
                } else {
                    if let user = user {
                        print("Current user: \(user)")
                        self.currentUser = user
                        
                        notificationCenter
                            .postNotificationName(DataCentralDidUpdateCurrentUser, object: nil)
                    }
                }
            }
        }
    }
    
}
