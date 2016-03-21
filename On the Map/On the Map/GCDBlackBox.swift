//
//  GCDBlackBox.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation

func performOnMain(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        block()
    }
}