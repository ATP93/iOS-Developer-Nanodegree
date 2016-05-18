//
//  MediumImage.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 17/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreData

//------------------------------------------------------------
// MARK: - MediumImage: NSManagedObject
//------------------------------------------------------------

class MediumImage: NSManagedObject {

    //--------------------------------------------------------
    // MARK: Init
    //--------------------------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(path: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(MediumImage.entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.path = path
    }

}

//------------------------------------------------------------
// MARK: - MediumImage: EntityNamelable - 
//------------------------------------------------------------

extension MediumImage: EntityNamelable {
    
    static var entityName: String {
        return "MediumImage"
    }
    
}
