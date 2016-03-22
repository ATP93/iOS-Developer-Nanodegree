//
//  StudentLocation+JSONParselable.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-----------------------------------------
// MARK: - StudentLocation: JSONParselable
//-----------------------------------------

extension StudentLocation: JSONParselable {
    
    static func decode(json: JSONDictionary) -> StudentLocation? {
        guard
            let objectId = JSON.string(json, key: StudentLocationKey.ObjectId.rawValue),
            let uniqueKey = JSON.string(json, key: StudentLocationKey.UniqueKey.rawValue),
            let firstName = JSON.string(json, key: StudentLocationKey.FirstName.rawValue),
            let lastName = JSON.string(json, key: StudentLocationKey.LastName.rawValue),
            let mapString = JSON.string(json, key: StudentLocationKey.MapString.rawValue),
            let mediaURLString = JSON.string(json, key: StudentLocationKey.MediaURL.rawValue),
            let mediaURL = NSURL(string: mediaURLString),
            let latitude = JSON.double(json, key: StudentLocationKey.Latitude.rawValue),
            let longitude = JSON.double(json, key: StudentLocationKey.Longitude.rawValue),
            let createdAt = JSON.string(json, key: StudentLocationKey.CreatedAt.rawValue),
            let updatedAt = JSON.string(json, key: StudentLocationKey.UpdatedAt.rawValue) else {
            return nil
        }
        
        let studentLocation = StudentLocation(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, createdAt: createdAt, updatedAt: updatedAt)
        
        return studentLocation
    }
    
}
