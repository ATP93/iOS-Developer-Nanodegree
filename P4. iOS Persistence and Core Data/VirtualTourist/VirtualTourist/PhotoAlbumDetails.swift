//
//  PhotoAlbumDetails.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 18/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreData

//------------------------------------------------------
// MARK: - PhotoAlbumDetails: NSManagedObject
//------------------------------------------------------

class PhotoAlbumDetails: NSManagedObject {
    
    //--------------------------------------------------
    // MARK: Properties
    //--------------------------------------------------
    
    private static var numberFormatter: NSNumberFormatter {
        get {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            
            return formatter
        }
    }

    //--------------------------------------------------
    // MARK: Init
    //--------------------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(PhotoAlbumDetails.entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        id = UUIDUtils.generateUUIDString()
    }
    
    convenience init?(json: JSONDictionary, context: NSManagedObjectContext) {
        guard let page = JSON.number(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Page),
            let pages = JSON.number(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Pages),
            let perPage = JSON.number(json, key: FlickrApiClient.Constants.FlickrResponseKeys.PerPage),
            let totalString = JSON.string(json, key: FlickrApiClient.Constants.FlickrResponseKeys.Total),
            let total = PhotoAlbumDetails.numberFormatter.numberFromString(totalString) else {
                return nil
        }
        
        self.init(context: context)
        
        self.page = page
        self.pages = pages
        self.perPage = perPage
        self.total = total
    }
    
    convenience init(album: PhotoAlbumDetails, context: NSManagedObjectContext) {
        self.init(context: context)
        copyValues(album)
    }
    
    //--------------------------------------------------
    // MARK: Methods
    //--------------------------------------------------
    
    func copyValues(album: PhotoAlbumDetails) {
        page = album.page
        pages = album.pages
        perPage = album.perPage
        total = album.total
    }
    
}

//---------------------------------------------
// MARK: - PhotoAlbumDetails: EntityNamelable -
//---------------------------------------------

extension PhotoAlbumDetails: EntityNamelable {
    
    static var entityName: String {
        return "PhotoAlbumDetails"
    }
    
}

