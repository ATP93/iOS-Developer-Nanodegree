//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 12/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreData
import MapKit

//--------------------------------------------
// MARK: - Pin: NSManagedObject
//--------------------------------------------

class Pin: NSManagedObject {
    
    //----------------------------------------
    // MARK: Properties
    //----------------------------------------
    
    static let entityName = "Pin"

    //----------------------------------------
    // MARK: Init
    //----------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Pin.entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = UUIDUtils.generateUUIDString()
    }
    
    convenience init(locationCoordinate location: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        self.init(context: context)
        
        latitude  = location.latitude
        longitude = location.longitude
    }

}

//--------------------------------------------
// MARK: - Pin: MKAnnotation
//--------------------------------------------

extension Pin: MKAnnotation {
    
    //--------------------------------------------
    // MARK: MKAnnotation
    //--------------------------------------------
    
    var coordinate: CLLocationCoordinate2D {
        return locationCoordinate()
    }
    
    //--------------------------------------------
    // MARK: Helpers
    //--------------------------------------------
    
    func locationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
    }
    
}
