//
//  AppDelegate.swift
//  MemeMe
//
//  Created by Ivan Magda on 11.04.16.
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
    
    private let memesPersistence = MemesPersistence()

    //-----------------------------------------------------
    // MARK: UIApplicationDelegate
    //-----------------------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setup()
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        memesPersistence.saveMemes()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        memesPersistence.saveMemes()
    }
    
    //-----------------------------------------------------
    // MARK: Setup
    //-----------------------------------------------------

    private func setup() {
        let tabBarController = window!.rootViewController as! UITabBarController
        let collectionNavigationController = tabBarController.viewControllers![1] as! UINavigationController
        
        let memesController = collectionNavigationController.topViewController as! MemesCollectionViewController
        memesController.memesPersistence = memesPersistence
    }
    
}
