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

    //-----------------------------------------
    // MARK: Init
    //-----------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Photo.entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        createdAt = NSDate()
    }
    
    convenience init?(json: JSONDictionary, context: NSManagedObjectContext) {
        guard let id = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Id),
            let thumbnailUrl = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.ThumbnailURL),
            let mediumUrl = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.MediumURL) else {
                return nil
        }
        
        self.init(context: context)
        
        self.id = id
        self.title = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Title)
        
        let thumbnailImage = ThumbnailImage(path: thumbnailUrl, context: context)
        let mediumImage = MediumImage(path: mediumUrl, context: context)
        
        let photoData = PhotoData(context: context)
        photoData.thumbnail = thumbnailImage
        photoData.medium = mediumImage
        
        self.photoData = photoData
    }
    
    //-----------------------------------------
    // MARK: Methods
    //-----------------------------------------
    
    class func sanitizedPhotos(json: [JSONDictionary], parentPin pin: Pin? = nil, context: NSManagedObjectContext) -> [Photo]? {
        return json.flatMap {
            let photo = Photo(json: $0, context: context)
            photo?.pin = pin
            return photo
        }
    }
    
}

//--------------------------------------------
// MARK: - Photo: EntityNamelable -
//--------------------------------------------

extension Photo: EntityNamelable {
    
    static var entityName: String {
        return "Photo"
    }
    
}
