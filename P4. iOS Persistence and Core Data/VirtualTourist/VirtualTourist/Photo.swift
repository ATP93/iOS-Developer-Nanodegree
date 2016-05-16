//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 12/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreData

//--------------------------------------------
// MARK: - Photo: NSManagedObject
//--------------------------------------------

class Photo: NSManagedObject {
    
    //----------------------------------------
    // MARK: Properties
    //----------------------------------------
    
    static let entityName = "Photo"

    //-----------------------------------------
    // MARK: Init
    //-----------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
}
