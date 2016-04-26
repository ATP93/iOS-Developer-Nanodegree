//
//  Constants.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

let BaseErrorDomain = "com.ivanmagda.On-the-Map"

//-------------------------------------
// MARK: - HttpApiClient (Constants)
//-------------------------------------

struct HttpApiClientError {
    static let EmptyResponseDomain = "\(BaseErrorDomain).emptyresponse"
}

enum HttpApiClientErrorCode: Int {
    case EmptyResponse = 12
}

//-------------------------------------
// MARK: - JsonApiClient (Constants)
//-------------------------------------

struct JsonApiClientError {
    static let EmptyResponseDomain = "\(BaseErrorDomain).emptyresponse"
    static let JSONDeserializingDomain = "\(BaseErrorDomain).jsonerror.deserializing"
    static let NotSuccsessfullResponseDomain = "\(BaseErrorDomain).badresponsecode"
}

enum JsonApiClientErrorCode: Int {
    case EmptyResponse = 12
    case JSONDeserializing = 50
    case NotSuccsessfullResponseStatusCode = 51
}

//--------------------------------------------
// MARK: - MatrixMathApiClient: (Constants)
//--------------------------------------------

//extension MatrixMathApiClient {
//    
//    // MARK: - Error
//    static let ErrorDomain = "\(BaseErrorDomain).MatrixMathApiClient"
//    static let ErrorCode = 100
//}

//-------------------------------------
// MARK: HTTTPMethodName
//-------------------------------------

enum HTTTPMethodName: String {
    case Get = "GET"
    case Post = "POST"
    case Delete = "DELETE"
}
