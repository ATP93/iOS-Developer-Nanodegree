//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 18/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var createdAt: NSDate
    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var pin: Pin?
    @NSManaged var photoData: PhotoData

}
