//
//  PathUtils.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 12/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//----------------------------------------------------
// MARK: - PathUtils
//----------------------------------------------------

class PathUtils {

    private init() {
    }

    //-------------------------------------------------
    // MARK: Static Functions
    //-------------------------------------------------
    
    class func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }
    
}
