//
//  StudentLocation+Alertable.swift
//  On the Map
//
//  Created by Ivan Magda on 22.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

extension StudentLocation: Alertable {
    
    func alert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Open user media link in Safari?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.openMediaURLInSafari()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        return alert
    }
    
}