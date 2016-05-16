//
//  GCDUtils.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 16/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

typealias GCDBlock = () -> Void

func performOnMain(block: GCDBlock) {
    dispatch_async(dispatch_get_main_queue()) {
        block()
    }
}

func performAfterOnMain(time: Double, block: GCDBlock) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        block()
    }
}
