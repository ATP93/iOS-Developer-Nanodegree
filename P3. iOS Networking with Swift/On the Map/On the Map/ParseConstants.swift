//
//  ParseConstants.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

extension ParseApiClient {
    
    // MARK: Constants
    struct Constant {
        
        // MARK: API Key
        static let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: REST API Key
        static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"
    }
    
    
    // MARK: Parameter Key
    struct ParameterKey {
        
        /// Specifies the maximum number of StudentLocation objects to return in the JSON response.
        static let limit = "limit"
        
        /// Use this parameter with limit to paginate through results.
        static let skip = "skip"
        
        /// A comma-separate list of key names that specify the sorted order of the results.
        static let order = "order"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Results = "results"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let UpdatedAt = "updatedAt"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Results = "results"
        static let CreatedAt = "createdAt"
        static let ObjectId = "objectId"
        static let UpdatedAt = "updatedAt"
    }
    
}
