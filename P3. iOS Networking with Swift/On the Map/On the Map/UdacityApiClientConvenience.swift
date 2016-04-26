//
//  UdacityApiClientConvenience.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import UIKit

typealias UdacityConvenientResultBlock = (success: Bool, error: NSError?) -> Void
typealias UdacityUserResultBlock = (user: User?, error: NSError?) -> Void

//--------------------------------------------------------
// MARK: - UdacityApiClient (Convenient Resource Methods)
//--------------------------------------------------------

extension UdacityApiClient {
    
    //----------------------------------------------------
    // MARK: Authentication (POST) method
    //----------------------------------------------------
    
    func authenticateWithUsername(username: String, password: String, completionHandler block: UdacityConvenientResultBlock) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dataTaskForPOSTMethod(UdacityApiClient.Methods.AuthenticationSession, parameters: nil, jsonBody: jsonBody, completionHandler: { (result, error) in
            func sendError(error: String) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                block(success: false, error: NSError(domain: "com.ivanmagda.On-the-Map.auth", code: 15, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let json = result else {
                sendError("Empty response")
                return
            }
            
            guard let session = json[UdacityApiClient.JSONResponseKeys.Session] as? [String: AnyObject],
            let sessionID = session[UdacityApiClient.JSONResponseKeys.SessionID] as? String,
                let expirationDate = session[UdacityApiClient.JSONResponseKeys.ExpirationDate] as? String else {
                    sendError("Could not find key: \(UdacityApiClient.JSONResponseKeys.SessionID)")
                    return
            }
            
            self.sessionID = sessionID
            self.expirationDate = expirationDate
            
            guard let account = json[UdacityApiClient.JSONResponseKeys.Account] as? [String: AnyObject],
                let userId = account[UdacityApiClient.JSONResponseKeys.UserID] as? String else {
                    sendError("Could not find key: \(UdacityApiClient.JSONResponseKeys.UserID)")
                    return
            }
            
            self.userID = userId
            
            // Persist information about the user account.
            UdacityApiClient.setUserValue(userId, forKey: UdacityApiClient.UserDefaults.UserID)
            UdacityApiClient.setUserValue(sessionID, forKey: UdacityApiClient.UserDefaults.SessionID)
            UdacityApiClient.setUserValue(expirationDate, forKey: UdacityApiClient.UserDefaults.ExpirationDate)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            block(success: true, error: nil)
        })
    }
    
    //----------------------------------------------------
    // MARK: Logging Out (DELETE) method
    //----------------------------------------------------
    
    func logOutWithCompletionHandler(block: UdacityConvenientResultBlock) {
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dataTaskForDELETEMethod(UdacityApiClient.Methods.LoggingOut, parameters: nil, headerFields: ["X-XSRF-TOKEN": xsrfCookie?.value]) { (result, error) in
            func sendError(error: String) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                block(success: false, error: NSError(domain: "com.ivanmagda.On-the-Map.logout", code: 16, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let _ = result else {
                sendError("Empty response")
                return
            }
            
            UdacityApiClient.logoutUser()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            block(success: true, error: nil)
        }
    }
    
    func getPublicUserData(userId: String, completionHandler block: UdacityUserResultBlock) {
        var mutableMethod: String = Methods.UserData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: URLKeys.UserID, value: String(UdacityApiClient.sharedInstance.userID!))!
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dataTaskForGETMethod(mutableMethod, parameters: nil) { (result, error) in
            func sendError(error: String) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                block(user: nil, error: NSError(domain: "com.ivanmagda.On-the-Map.getPublicUserData", code: 17, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let userJSON = result?[UserKey.UserRootKey.rawValue] as? JSONDictionary else {
                sendError("Empty response")
                return
            }
            
            let user = User.decode(userJSON)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            block(user: user, error: nil)
        }
    }
    
}
