//
//  JsonApiClient.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-------------------------------------
// MARK: Typealiases
//-------------------------------------

typealias JsonDeserializingCompletionHandler = (jsonObject: AnyObject?, error: NSError?) -> Void

//--------------------------------------
// MARK: - JsonApiClient: HttpApiClient
//--------------------------------------

class JsonApiClient: HttpApiClient {
    
    //----------------------------------
    // MARK: Data Tasks
    //----------------------------------
    
    func fetchJson(request: NSURLRequest, completionHandler: TaskCompletionHandler) {
        fetchRawData(request) { result in
            switch result {
            case .RawData(let data):
                // Deserializing the JSON data.
                self.deserializeJsonData(data) { (jsonObject, error) in
                    guard error == nil else {
                        completionHandler(.Error(error!))
                        return
                    }
                    
                    // Try to give raw JSON a usable Foundation object form.
                    guard let json = jsonObject as? JSONDictionary else {
                        let errorMessage = "Could not cast the JSON object as JSONDictionary: '\(jsonObject)'"
                        self.debugLog(errorMessage)
                        
                        let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                        let error = NSError(domain: JsonApiClientError.JSONDeserializingDomain,
                                            code: JsonApiClientErrorCode.JSONDeserializing.rawValue, userInfo: userInfo)
                        completionHandler(.Error(error))
                        return
                    }
                    
                    completionHandler(.Json(json))
                }
            default:
                completionHandler(result)
            }
        }
    }
    
    //---------------------------------
    // MARK: JSON Deserializing
    //---------------------------------
    
    func deserializeJsonData(data: NSData, completionHandler: JsonDeserializingCompletionHandler) {
        var deserializedJSON: AnyObject?
        
        do {
            deserializedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch let error as NSError {
            completionHandler(jsonObject: nil, error: error)
        }
        
        completionHandler(jsonObject: deserializedJSON, error: nil)
    }
    
}
