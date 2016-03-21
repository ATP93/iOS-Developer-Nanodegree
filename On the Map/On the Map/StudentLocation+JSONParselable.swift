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
            let objectId = JSON.string(json, key: StudentLocationKeys.ObjectId.rawValue),
            let uniqueKey = JSON.string(json, key: StudentLocationKeys.UniqueKey.rawValue),
            let firstName = JSON.string(json, key: StudentLocationKeys.FirstName.rawValue),
            let lastName = JSON.string(json, key: StudentLocationKeys.LastName.rawValue),
            let mapString = JSON.string(json, key: StudentLocationKeys.MapString.rawValue),
            let mediaURLString = JSON.string(json, key: StudentLocationKeys.MediaURL.rawValue),
            let mediaURL = NSURL(string: mediaURLString),
            let latitude = JSON.float(json, key: StudentLocationKeys.Latitude.rawValue),
            let longitude = JSON.float(json, key: StudentLocationKeys.Longitude.rawValue),
            let createdAt = JSON.string(json, key: StudentLocationKeys.CreatedAt.rawValue),
            let updatedAt = JSON.string(json, key: StudentLocationKeys.UpdatedAt.rawValue) else {
            return nil
        }
        
        let studentLocation = StudentLocation(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, createdAt: createdAt, updatedAt: updatedAt)
        
        return studentLocation
    }
    
}
