//
//  ScreenSize.swift
//  MemeMe
//
//  Created by Ivan Magda on 16.04.16.
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
