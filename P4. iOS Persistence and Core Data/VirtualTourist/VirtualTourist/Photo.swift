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
        createdAt = NSDate()
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Photo.entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init?(json: JSONDictionary, context: NSManagedObjectContext) {
        self.init(context: context)
        
        guard let id = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Id),
        let url = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.MediumURL) else {
            return nil
        }
        
        self.id = id
        self.photoPath = url
        self.title = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Title)
    }
    
    //-----------------------------------------
    // MARK: Methods
    //-----------------------------------------
    
    class func sanitizedPhotos(json: [JSONDictionary], context: NSManagedObjectContext) -> [Photo]? {
        return json.flatMap { Photo(json: $0, context: context) }
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
