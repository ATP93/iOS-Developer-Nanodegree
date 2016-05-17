//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 11/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//---------------------------------------------------------
// MARK: - AppDelegate: UIResponder, UIApplicationDelegate
//---------------------------------------------------------

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //-----------------------------------------------------
    // MARK: Properties
    //-----------------------------------------------------
    
    var window: UIWindow?
    
    private let coreDataStackManager = CoreDataStackManager.sharedInstance()
    private let persistenceCentral = PersistenceCentral.sharedInstance()
    private let flickrApiClient = FlickrApiClient.sharedInstance

    //-----------------------------------------------------
    // MARK: UIApplicationDelegate
    //-----------------------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        spreadSharedInstances()
        UserDefaultsUtils.activate()
        
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        UserDefaultsUtils.synchronize()
        coreDataStackManager.saveContext()
    }
    
    //-----------------------------------------------------
    // MARK: Helpers
    //-----------------------------------------------------
    
    private func spreadSharedInstances() {
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsVC = navigationController.topViewController as! TravelLocationsViewController
        travelLocationsVC.coreDataStackManager = coreDataStackManager
        travelLocationsVC.persistenceCentral = persistenceCentral
        travelLocationsVC.flickrApiClient = flickrApiClient
    }
    
}
