//
//  PhotoData+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 17/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhotoData {

    @NSManaged var id: String
    @NSManaged var photo: Photo?
    @NSManaged var thumbnail: ThumbnailImage?
    @NSManaged var medium: MediumImage?

}
