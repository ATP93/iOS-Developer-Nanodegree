//
//  UdacityApiClient.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

typealias UdacityTaskCompletionHandler = (result: JSONDictionary?, error: NSError?) -> Void

//-----------------------------------------
// MARK: - UdacityApiClient: HttpApiClient
//-----------------------------------------

final class UdacityApiClient: JsonApiClient {

    //------------------------------------
    // MARK: - Properties
    //------------------------------------
    
    // Authentication.
    var sessionID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaults.SessionID)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaults.SessionID)
        }
    }
    
    var userID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaults.UserID)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaults.UserID)
        }
    }
    
    var expirationDate: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaults.ExpirationDate)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaults.ExpirationDate)
        }
    }
    
    static var sharedInstance: UdacityApiClient = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let client = UdacityApiClient(configuration: config)
        client.loggingEnabled = true
        
        return client
    }()
    
    var isUserLoggedIn: Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let userID = userDefaults.objectForKey(UdacityApiClient.UserDefaults.UserID) as? String where !userID.isEmpty else {
            return false
        }
        
        return true
    }

    //------------------------------------
    // MARK: - GET
    //------------------------------------
    
    func dataTaskForGETMethod(method: String, parameters: [String: AnyObject]?, completionHandler block: UdacityTaskCompletionHandler) {
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = HTTTPMethodName.Get.rawValue
        fetchRawData(request) { (data, response, error) in
            self.checkRespose(data, httpResponse: response, error: error, completionHandler: block)
        }
    }
    
    //------------------------------------
    // MARK: - POST
    //------------------------------------
    
    func dataTaskForPOSTMethod(method: String, parameters: [String: AnyObject]?, jsonBody: String, completionHandler: UdacityTaskCompletionHandler) {
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = HTTTPMethodName.Post.rawValue
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        fetchRawData(request) { (data, response, error) in
            self.checkRespose(data, httpResponse: response, error: error, completionHandler: completionHandler)
        }
    }
    
    //------------------------------------
    // MARK: - DELETE
    //------------------------------------
    
    func dataTaskForDELETEMethod(method: String, parameters: [String: AnyObject]?, headerFields: [String: String?]?, completionHandler: UdacityTaskCompletionHandler) {
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = HTTTPMethodName.Delete.rawValue
    
        if let headerFields = headerFields {
            for (key, value) in headerFields {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        fetchRawData(request) { (data, response, error) in
            self.checkRespose(data, httpResponse: response, error: error, completionHandler: completionHandler)
        }

    }
    
    //------------------------------------
    // MARK: - Helpers
    //------------------------------------
    
    // Substitute the key for the value that is contained within the method name.
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    class func setUserValue(value: AnyObject?, forKey key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
    }
    
    class func logoutUser() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(UserDefaults.UserID)
        defaults.removeObjectForKey(UserDefaults.SessionID)
        defaults.removeObjectForKey(UserDefaults.ExpirationDate)
        defaults.removeObjectForKey(UserDefaults.CurrentUser)
        defaults.synchronize()
    }
    
    /// Create a URL from parameters.
    private func udacityURLFromParameters(parameters: [String: AnyObject]?, withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = UdacityApiClient.Constant.ApiScheme
        components.host = UdacityApiClient.Constant.ApiHost
        components.path = UdacityApiClient.Constant.ApiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
    }
    
    private func skipSecurityCharactersInData(data: NSData) -> NSData {
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
    
    private func checkRespose(data: NSData?, httpResponse: NSHTTPURLResponse?, error: NSError?, completionHandler: UdacityTaskCompletionHandler) {
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(result: nil, error: NSError(domain: "com.ivanmagda.On-the-Map.taskForPOSTMethod", code: 1, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError("There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = httpResponse?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            sendError("Failed to Login, try again")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError("No data was returned by the request!")
            return
        }
        
        let newData = self.skipSecurityCharactersInData(data)
        
        /* Parse the data and use the data (happens in completion handler) */
        self.deserializeJSONDataWithCompletionHandler(newData) { (result, error) in
            if let _ = error {
                sendError("Could not parse the data as JSON: '\(newData)'")
            } else {
                if let json = result as? JSONDictionary {
                    completionHandler(result: json, error: nil)
                } else {
                    sendError("Failed to cast type of the json object: \(result)")
                }
            }
        }
    }

}
