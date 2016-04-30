//
//  StudentLocationAnnotation.swift
//  On the Map
//
//  Created by Ivan Magda on 30.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import MapKit

//-------------------------------------------------
// MARK: - StudentLocationAnnotation: NSObject
//-------------------------------------------------

class StudentLocationAnnotation: NSObject {
    
    //----------------------------------------------
    // MARK: Properties
    //----------------------------------------------
    
    let studentLocation: StudentLocation
    
    //----------------------------------------------
    // MARK: Init
    //----------------------------------------------
    
    init(location: StudentLocation) {
        studentLocation = location
    }
    
}

//-------------------------------------------------
// MARK: - StudentLocationAnnotation: MKAnnotation
//-------------------------------------------------

extension StudentLocationAnnotation: MKAnnotation {

    // Center latitude and longitude of the annotation view.
    var coordinate: CLLocationCoordinate2D {
        return studentLocation.location.coordinate
    }

    var title: String? {
        return "\(studentLocation.firstName) \(studentLocation.lastName)"
    }

    var subtitle: String? {
        return studentLocation.mediaURL.absoluteString
    }

}

//-------------------------------------------------
// MARK: - StudentLocationAnnotation: Alertable
//-------------------------------------------------

extension StudentLocationAnnotation: Alertable {
    
    //---------------------------------------------
    // MARK: Alertable
    //---------------------------------------------
    
    func alert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Open user media link in Safari?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.openMediaURLInSafari()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        return alert
    }
    
    //---------------------------------------------
    // MARK: Helpers
    //---------------------------------------------
    
    func openMediaURLInSafari() {
        let application = UIApplication.sharedApplication()
        
        if application.canOpenURL(studentLocation.mediaURL) {
            application.openURL(studentLocation.mediaURL)
        }
    }
    
}
