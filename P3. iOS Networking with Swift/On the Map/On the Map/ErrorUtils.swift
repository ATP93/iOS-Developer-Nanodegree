//
//  Constants.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

private let BaseErrorDomain = "com.ivanmagda.On-the-Map"

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
// MARK: - UdacityApiClient: (Constants) -
//----------------------------------------

extension UdacityApiClient {
    
    // MARK: Error
    static let ErrorDomain = "\(BaseErrorDomain).Udacity-Api-Client"
    static let ErrorCode = 100
    
    static let UserAuthDomain = "\(ErrorDomain).auth"
    static let UserAuthErrorCode = 15
    
    static let UserLogoutDomain = "\(ErrorDomain).logout"
    static let UserLogoutErrorCode = 16
    
    static let GetPublicUserDataDomain = "\(ErrorDomain).get-public-user-data"
    static let GetPublicUserDataErrorCode = 17
}

//--------------------------------------
// MARK: - ParseApiClient: (Constants) -
//--------------------------------------

extension ParseApiClient {
    
    // MARK: Error
    static let ErrorDomain = "\(BaseErrorDomain).Parse-Api-Client"
    static let ErrorCode = 200
    
    static let GetStudentLocationsDomain = "\(ErrorDomain).get-student-locations"
    static let GetStudentLocationsErrorCode = 17
    
    static let PostStudentLocationDomain = "\(ErrorDomain).post-student-location"
    static let PostStudentLocationErrorCode = 20
    
    static let GetStudentLocationDomain = "\(ErrorDomain).get-student-location"
    static let GetStudentLocationErrorCode = 21
}
