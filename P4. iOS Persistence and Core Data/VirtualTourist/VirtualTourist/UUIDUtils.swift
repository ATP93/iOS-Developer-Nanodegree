//
//  UUIDUtils.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 12/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-------------------------------------------------
// MARK: - UUIDUtils
//-------------------------------------------------

class UUIDUtils {
    
    private init() {
    }

    //-------------------------------------------------
    // MARK: Static Functions
    //-------------------------------------------------
    
    class func generateUUIDString() -> String {
        return NSUUID().UUIDString
    }
    
}
