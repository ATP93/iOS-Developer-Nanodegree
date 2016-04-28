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
typealias ParseGetStudentLocationsCompletionHandler = (locations: [StudentLocation]?, error: NSError?) -> Void
typealias ParseGetStudentLocationCompletionHandler = (location: StudentLocation?, error: NSError?) -> Void

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
            "X-Parse-REST-API-Key": Constant.RestApiKey,
            "Content-Type": "application/json"
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
    
    func getStudentLocationsWithCompletionHandler(completionHandler: ParseGetStudentLocationsCompletionHandler) {
        let request = NSURLRequest(URL: parseURLFromParameters([
                ParameterKey.order: "-\(JSONBodyKeys.UpdatedAt)",
                ParameterKey.limit: "200"
            ])
        )
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
    
    func getStudentLocationWithId(id: String, completionHandler: ParseGetStudentLocationCompletionHandler) {
        let request = NSURLRequest(URL: parseURLFromParameters(
            ["where": "{\"\(JSONBodyKeys.UniqueKey)\":\"\(id)\"}"])
        )
        fetchJson(request) { (result) in
            func sendError(error: String) {
                self.debugLog(error)
                let error = NSError(
                    domain: ParseApiClient.GetStudentLocationDomain,
                    code: ParseApiClient.GetStudentLocationErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : error]
                )
                completionHandler(location: nil, error: error)
            }
            
            switch result {
            case .Error(let error):
                sendError(error.localizedDescription)
            case .Json(let json):
                guard let results = json[JSONResponseKeys.Results] as? [JSONDictionary] where
                    results.count == 1 else {
                        sendError("Failed to parse json")
                        return
                }
                
                completionHandler(location: StudentLocation.decode(results[0]), error: nil)
            default:
                sendError(result.defaultErrorMessage()!)
            }
        }
    }
    
    func postLocationForStudent(student: User, placemark: CLPlacemark, mediaURL: String, completionHandler: ParseTaskCompletionHandler) {
        guard let httpBody = generateLocationHttpBody(student: student, placemark: placemark, mediaURL: mediaURL) else {
            completionHandler(success: false, error: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil))
        request.HTTPMethod = HttpMethodName.Post.rawValue
        request.HTTPBody = httpBody
        
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
    
    func updateStudentLocation(location: StudentLocation, student: User, placemark: CLPlacemark, mediaURL: String, completionHandler: ParseTaskCompletionHandler) {
        guard let httpBody = generateLocationHttpBody(student: student, placemark: placemark, mediaURL: mediaURL) else {
            completionHandler(success: false, error: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil, withPathExtension: "/\(location.objectId)"))
        request.HTTPMethod = HttpMethodName.Put.rawValue
        request.HTTPBody = httpBody
        
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
                guard let updatedAt = json[JSONResponseKeys.UpdatedAt] as? String else {
                        sendError("Failed to access response key")
                        return
                }
                self.debugLog("Successfully updated location: \(location.objectId), at: \(updatedAt)")
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
    
    private func generateLocationHttpBody(student student: User, placemark: CLPlacemark, mediaURL: String) -> NSData? {
        guard let coordinate = placemark.location?.coordinate else {
            return nil
        }
        
        return "{\"\(JSONBodyKeys.UniqueKey)\": \"\(student.id)\", \"\(JSONBodyKeys.FirstName)\": \"\(student.firstName)\", \"\(JSONBodyKeys.LastName)\": \"\(student.lastName)\",\"\(JSONBodyKeys.MapString)\": \"\(placemark.name!)\", \"\(JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(JSONBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JSONBodyKeys.Longitude)\": \(coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
    }
    
}