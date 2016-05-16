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
    // MARK: Types
    //----------------------------------------
    
    enum Keys: String {
        case id
        case createdAt
        case pin
    }

    //-----------------------------------------
    // MARK: Init
    //-----------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = UUIDUtils.generateUUIDString()
        createdAt = NSDate()
    }
    
}

//--------------------------------------------
// MARK: - Photo: EntityNamelable
//--------------------------------------------

extension Photo: EntityNamelable {
    
    static var entityName: String {
        return "Photo"
    }
    
}
