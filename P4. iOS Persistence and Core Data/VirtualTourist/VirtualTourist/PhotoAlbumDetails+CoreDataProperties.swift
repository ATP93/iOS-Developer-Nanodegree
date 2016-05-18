//
//  PhotoAlbumDetails+CoreDataProperties.swift
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

extension PhotoAlbumDetails {

    @NSManaged var id: String
    @NSManaged var page: NSNumber
    @NSManaged var pages: NSNumber
    @NSManaged var total: NSNumber
    @NSManaged var perPage: NSNumber
    @NSManaged var pin: Pin?

}
