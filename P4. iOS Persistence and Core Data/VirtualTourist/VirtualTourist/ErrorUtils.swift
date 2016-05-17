//
//  Constants.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

private let BaseErrorDomain = "com.ivanmagda.VirtualTourist"

//----------------------------------
// MARK: HttpApiClient (Constants) -
//----------------------------------

struct HttpApiClientError {
    static let BadResponseDomain = "\(BaseErrorDomain).bad-response"
    static let EmptyResponseDomain = "\(BaseErrorDomain).empty-response"
}

enum HttpApiClientErrorCode: Int {
    case BadResponse = 12
    case EmptyResponse = 13
}

//------------------------------------
// MARK: - JsonApiClient (Constants) -
//------------------------------------

struct JsonApiClientError {
    static let EmptyResponseDomain = "\(BaseErrorDomain).empty-response"
    static let JSONDeserializingDomain = "\(BaseErrorDomain).jsonerror.deserializing"
    static let NotSuccsessfullResponseDomain = "\(BaseErrorDomain).bad-response-code"
}

enum JsonApiClientErrorCode: Int {
    case EmptyResponse = 12
    case JSONDeserializing = 50
    case NotSuccsessfullResponseStatusCode = 51
}

//----------------------------------------
// MARK: - FlickrApiClient: (Constants) -
//----------------------------------------

extension FlickrApiClient {
    
    // MARK: Error
    static let ErrorDomain = "\(BaseErrorDomain).Flickr-Api-Client"
    static let ErrorCode = 100
    
    static let NumberOfPagesForPhotoSearchErrorDomain = "\(ErrorDomain).number-of-pages"
    static let NumberOfPagesForPhotoSearchErrorCode = 15
    
    static let FetchPhotosErrorDomain = "\(ErrorDomain).fetch-photos"
    static let FetchPhotosErrorCode = 16
    
    static let FetchPhotosByCoordinateErrorDomain = "\(ErrorDomain).fetch-photos-by-coordinate"
    static let FetchPhotosByCoordinateErrorCode = 17
}
