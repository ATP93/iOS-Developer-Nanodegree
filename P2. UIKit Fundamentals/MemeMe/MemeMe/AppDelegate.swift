/**
 * Copyright (c) 2017 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: Properties
  
  var window: UIWindow?
  
  private let memesPersistence = MemesPersistence()
  
  // MARK: UIApplicationDelegate
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    injectViewControllers()
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    memesPersistence.saveMemes()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    memesPersistence.saveMemes()
  }
  
  // MARK: Setup
  
  private func injectViewControllers() {
    let tabBarController = window!.rootViewController as! UITabBarController
    let tableNavigationController = tabBarController.viewControllers![0] as! UINavigationController
    let collectionNavigationController = tabBarController.viewControllers![1] as! UINavigationController
    
    let tableController = tableNavigationController.topViewController as! MemesTableViewController
    tableController.memesPersistence = memesPersistence
    
    let collectionController = collectionNavigationController.topViewController as! MemesCollectionViewController
    collectionController.memesPersistence = memesPersistence
  }
  
}
