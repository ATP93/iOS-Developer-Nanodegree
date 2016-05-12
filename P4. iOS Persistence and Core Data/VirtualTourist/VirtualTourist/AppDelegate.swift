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

    //-----------------------------------------------------
    // MARK: UIApplicationDelegate
    //-----------------------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        spreadCoreDataStack()
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStackManager.saveContext()
    }
    
    //-----------------------------------------------------
    // MARK: Helpers
    //-----------------------------------------------------
    
    private func spreadCoreDataStack() {
        let travelLocationsVC = window?.rootViewController as! TravelLocationsViewController
        travelLocationsVC.coreDataStackManager = coreDataStackManager
    }
    
}
