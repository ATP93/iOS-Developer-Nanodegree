//
//  ParseApiClient.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import MapKit

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
        
        let client = ParseApiClient(configuration: config)
        client.loggingEnabled = true
        
        return client
    }()
    
    //-----------------------------------
    // MARK: Network
    //-----------------------------------
    
    func getStudentLocationsWithCompletionHandler(block: (locations: [StudentLocation]?, error: NSError?) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil, withPathExtension: nil))
        request.HTTPMethod = HTTTPMethodName.Get.rawValue
        
        fetchJSON(request) { (result) in
            func sendError(error: String) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                block(locations: nil, error: NSError(domain: "com.ivanmagda.On-the-Map.parse.getStudentLocations", code: 17, userInfo: userInfo))
            }
            
            switch result {
            case .ClientError(let code):
                sendError("Client's error with code: \(code). Please try again later.")
            case .Error(let error):
                sendError(error.localizedDescription)
            case .Success(let json):
                guard let results = json[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                    sendError("Could not find \(JSONResponseKeys.Results) key in JSON: \(json)")
                    return
                }
                
                if let locations = StudentLocation.sanitizedStudentLocations(results) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    block(locations: locations, error: nil)
                } else {
                    sendError("Failed to sanitized student locations with results: \(results)")
                }
            default:
                sendError("There is an error occured. Try again.")
            }
        }
    }
    
    func postStudentLocation(student: User, placemark: CLPlacemark, mediaURL: String, block: (success: Bool, error: NSError?) -> Void) {
        guard let coordinate = placemark.location?.coordinate else {
            block(success: false, error: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil, withPathExtension: nil))
        request.HTTPMethod = HTTTPMethodName.Post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"\(JSONBodyKeys.UniqueKey)\": \"\(student.id)\", \"\(JSONBodyKeys.FirstName)\": \"\(student.firstName)\", \"\(JSONBodyKeys.LastName)\": \"\(student.lastName)\",\"\(JSONBodyKeys.MapString)\": \"\(placemark.name!)\", \"\(JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(JSONBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JSONBodyKeys.Longitude)\": \(coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        fetchJSON(request) { (result) in
            func sendError(error: String) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                block(success: false, error: NSError(domain: "com.ivanmagda.On-the-Map.parse.postStudentLocation", code: 20, userInfo: userInfo))
            }
            
            switch result {
            case .ClientError(let code):
                sendError("Client's error with code: \(code). Please try again later.")
            case .Error(let error):
                sendError(error.localizedDescription)
            case .Success(let json):
                guard let createdAt = json[JSONResponseKeys.CreatedAt] as? String,
                    let objectId = json[JSONResponseKeys.ObjectId] as? String else {
                        sendError("Failed to access response keys. Probably your locations did not post")
                      return
                }
                print("Posted location id: \(objectId), createdAt: \(createdAt)")
                block(success: true, error: nil)
            default:
                sendError("There is an error occured. Try again.")
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