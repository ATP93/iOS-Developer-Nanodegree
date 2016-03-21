//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

typealias JSONTaskCompletionHandler = (JSONDictionary?, NSHTTPURLResponse?, NSError?) -> Void
typealias TaskCompletionHandler = (NSData?, NSHTTPURLResponse?, NSError?) -> Void

//-------------------------------------
// MARK: - ApiClient
//-------------------------------------

class ApiClient {

    //---------------------------------
    // MARK: - Properties -
    //---------------------------------
    
    let configuration: NSURLSessionConfiguration
    
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.configuration)
    }()
    
    var currentTasks: Set<NSURLSessionDataTask> = []
    
    /// If value is `true` then debug messages will be logged.
    var loggingEnabled = false
    
    //---------------------------------
    // MARK: - Initializers -
    //---------------------------------
    
    init(configuration: NSURLSessionConfiguration) {
        self.configuration = configuration
    }
    
    //---------------------------------
    // MARK: - Network -
    //---------------------------------
    
    func cancelAllRequests() {
        for task in self.currentTasks {
            task.cancel()
        }
        self.currentTasks = []
    }
    
    //---------------------------------
    // MARK: Data Tasks
    //---------------------------------
    
    func fetch(request: NSURLRequest, completion: TaskCompletionHandler) {
        let task = dataTaskWithRequest(request, completion: completion)
        task.resume()
    }
    
    func dataTaskWithRequest(request: NSURLRequest, completion: TaskCompletionHandler) -> NSURLSessionDataTask {
        var task: NSURLSessionDataTask?
        task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            self.currentTasks.remove(task!)
            let httpResponse = response as! NSHTTPURLResponse
            
            if let error = error {
                self.debugLog("Received an error from HTTP \(request.HTTPMethod!) to \(request.URL!)")
                self.debugLog("Error: \(error)")
                completion(nil, httpResponse, error)
            } else {
                self.debugLog("Received HTTP \(httpResponse.statusCode) from \(request.HTTPMethod!) to \(request.URL!)")
                
                if let data = data {
                    completion(data, httpResponse, nil)
                } else {
                    self.debugLog("Received an empty response")
                    let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request"]
                    completion(nil, httpResponse, NSError(domain: "com.ivanmagda.On-the-Map.emptyresponse", code: 12, userInfo: userInfo))
                }
            }
        })
        
        currentTasks.insert(task!)
        
        return task!
    }
    
    //---------------------------------
    // MARK: With JSON Tasks
    //---------------------------------
    
    func fetchWithResult(request: NSURLRequest, completion: ApiClientResult -> Void) {
        let task = jsonDataTaskWithRequest(request) { (json, response, error) in
            performOnMain {
                if let error = error {
                    completion(.Error(error))
                } else {
                    // Did we get a successful 2XX response?
                    
                    switch response!.statusCode {
                    case 200:
                        completion(.Success(json!))
                    case 404: completion(.NotFound)
                    case 400...499: completion(.ClientError(response!.statusCode))
                    case 500...599: completion(.ServerError(response!.statusCode))
                    default:
                        let statusCode = response!.statusCode
                        print("Received HTTP \(statusCode), which was not handled")
                        // Should not happen.
                        completion(ApiClientResult.UnexpectedError(statusCode, error))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func jsonDataTaskWithRequest(request: NSURLRequest, completion: JSONTaskCompletionHandler) -> NSURLSessionDataTask {
        let task = dataTaskWithRequest(request) { (data, httpResponse, error) in
            if let data = data {
                // Parse the data and use the data.
                self.convertDataWithCompletionHandler(data) { (json, error) in
                    if let error = error {
                        completion(nil, httpResponse, error)
                    } else {
                        // Try to give raw JSON a usable Foundation object form.
                        if let json = json as? JSONDictionary {
                            completion(json, httpResponse, nil)
                        } else {
                            let userInfo = [NSLocalizedDescriptionKey: "Could not cast the JSON object as JSONDictionary: '\(json)'"]
                            completion(nil, httpResponse, NSError(domain: "com.ivanmagda.On-the-Map.jsonerror", code: 11, userInfo: userInfo))
                        }
                    }
                }
            }
        }
        
        return task
    }
    
    //---------------------------------
    // MARK: Helpers
    //---------------------------------
    
    func convertDataWithCompletionHandler(data: NSData, block: (AnyObject?, NSError?) -> Void) {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            block(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        block(parsedResult, nil)
    }
    
    //---------------------------------
    // MARK: Debug Logging
    //---------------------------------
    
    func debugLog(msg: String) {
        guard loggingEnabled else { return }
        print(msg)
    }
    
    func debugResponseData(data: NSData) {
        guard loggingEnabled else { return }
        if let body = String(data: data, encoding: NSUTF8StringEncoding) {
            print(body)
        } else {
            print("<empty response>")
        }
    }
    
}