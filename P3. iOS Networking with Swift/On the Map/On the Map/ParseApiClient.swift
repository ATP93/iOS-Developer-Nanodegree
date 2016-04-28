//
//  ParseApiClient.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import MapKit

//-------------------------------------
// MARK: Typealiases
//-------------------------------------

typealias ParseTaskCompletionHandler = (success: Bool, error: NSError?) -> Void
typealias ParseStudentLocationsCompletionHandler = (locations: [StudentLocation]?, error: NSError?) -> Void

//---------------------------------------
// MARK: - ParseApiClient: JsonApiClient
//---------------------------------------

class ParseApiClient: JsonApiClient {
    
    //-----------------------------------
    // MARK: Properties
    //-----------------------------------
    
    static var sharedInstance: ParseApiClient = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = [
            "X-Parse-Application-Id": Constant.ApplicationId,
            "X-Parse-REST-API-Key": Constant.RestApiKey
        ]
        config.timeoutIntervalForRequest  = 30.0
        config.timeoutIntervalForResource = 60.0
        
        let client = ParseApiClient(configuration: config)
        client.loggingEnabled = true
        
        return client
    }()
    
    //-----------------------------------
    // MARK: Network
    //-----------------------------------
    
    func getStudentLocationsWithCompletionHandler(completionHandler: ParseStudentLocationsCompletionHandler) {
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil, withPathExtension: nil))
        request.HTTPMethod = HttpMethodName.Get.rawValue
        
        fetchJson(request) { (result) in
            func sendError(error: String) {
                self.debugLog(error)
                let error = NSError(
                    domain: ParseApiClient.GetStudentLocationsDomain,
                    code: ParseApiClient.GetStudentLocationsErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : error]
                )
                completionHandler(locations: nil, error: error)
            }
            
            switch result {
            case .Error(let error):
                sendError(error.localizedDescription)
            case .Json(let json):
                guard let results = json[JSONResponseKeys.Results] as? [JSONDictionary] else {
                    sendError("Could not find \(JSONResponseKeys.Results) key in JSON: \(json)")
                    return
                }
                
                guard let locations = StudentLocation.sanitizedStudentLocations(results) else {
                    sendError("Failed to sanitized student locations with results: \(results)")
                    return
                }
                
                completionHandler(locations: locations, error: nil)
            default:
                sendError(result.defaultErrorMessage()!)
            }
        }
    }
    
    func postStudentLocation(student student: User, placemark: CLPlacemark, mediaURL: String, completionHandler: ParseTaskCompletionHandler) {
        guard let coordinate = placemark.location?.coordinate else {
            completionHandler(success: false, error: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil, withPathExtension: nil))
        request.HTTPMethod = HttpMethodName.Post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"\(JSONBodyKeys.UniqueKey)\": \"\(student.id)\", \"\(JSONBodyKeys.FirstName)\": \"\(student.firstName)\", \"\(JSONBodyKeys.LastName)\": \"\(student.lastName)\",\"\(JSONBodyKeys.MapString)\": \"\(placemark.name!)\", \"\(JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(JSONBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JSONBodyKeys.Longitude)\": \(coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        fetchJson(request) { (result) in
            func sendError(error: String) {
                self.debugLog(error)
                let error = NSError(
                    domain: ParseApiClient.PostStudentLocationDomain,
                    code: ParseApiClient.PostStudentLocationErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : error]
                )
                completionHandler(success: false, error: error)
            }
            
            switch result {
            case .Error(let error):
                sendError(error.localizedDescription)
            case .Json(let json):
                guard let createdAt = json[JSONResponseKeys.CreatedAt] as? String,
                      let objectId = json[JSONResponseKeys.ObjectId] as? String else {
                        sendError("Failed to access response keys. Probably your locations did not post")
                      return
                }
                self.debugLog("Posted location id: \(objectId), createdAt: \(createdAt)")
                completionHandler(success: true, error: nil)
            default:
                sendError(result.defaultErrorMessage()!)
            }
        }
    }
    
    //-----------------------------------
    // MARK: Helpers
    //-----------------------------------
    
    /// Create a URL from parameters.
    private func parseURLFromParameters(parameters: [String: AnyObject]?, withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constant.ApiScheme
        components.host = Constant.ApiHost
        components.path = Constant.ApiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
    }
    
}