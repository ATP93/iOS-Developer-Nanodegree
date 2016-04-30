//
//  UIUtility.swift
//  On the Map
//
//  Created by Ivan Magda on 28.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------
// MARK: Screen Sizes
//------------------------------------------------

public func screenBounds() -> CGRect {
    return UIScreen.mainScreen().bounds
}

public func screenSize() -> CGSize {
    return UIScreen.mainScreen().bounds.size
}

//------------------------------------------------
// MARK: Network Indicator
//------------------------------------------------

public func showNetworkActivityIndicator() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
}

public func hideNetworkActivityIndicator() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
}

let kDarkModerateBlue = UIColor(red: 50.0 / 255.0, green: 89.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)

