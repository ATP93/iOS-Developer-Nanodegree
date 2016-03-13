//
//  GCDBlackBox.swift
//
//  Created by Ivan Magda on 13.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}