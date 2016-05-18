//
//  PhotoData.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 17/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreData

//------------------------------------------------------------
// MARK: - PhotoData: NSManagedObject
//------------------------------------------------------------

class PhotoData: NSManagedObject {
    
    //--------------------------------------------------------
    // MARK: Init
    //--------------------------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(PhotoData.entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        id = UUIDUtils.generateUUIDString()
    }

}

//------------------------------------------------------------
// MARK: - PhotoData: EntityNamelable - 
//------------------------------------------------------------

extension PhotoData: EntityNamelable {
    
    static var entityName: String {
        return "PhotoData"
    }
    
}
