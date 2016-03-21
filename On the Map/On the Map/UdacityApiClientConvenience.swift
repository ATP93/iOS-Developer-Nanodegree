//
//  UdacityApiClientConvenience.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import UIKit

//--------------------------------------------------------
// MARK: - UdacityApiClient (Convenient Resource Methods)
//--------------------------------------------------------

extension UdacityApiClient {
    
    //----------------------------------------------------
    // MARK: Authentication (POST) methods
    //----------------------------------------------------
    
    func authenticateWithUsername(username: String, password: String, andCompletionHandler block: (Bool, NSError?) -> Void) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dataTaskForPOSTMethod(UdacityApiClient.Methods.AuthenticationSession, parameters: nil, jsonBody: jsonBody, completionHandlerForPOST: { (result, error) in
            func sendError(error: String) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                block(false, NSError(domain: "com.ivanmagda.On-the-Map.auth", code: 15, userInfo: userInfo))
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
            
            // Persist information about the user account .
            self.setUserValue(userId, forKey: UdacityApiClient.UserDefaults.UserID)
            self.setUserValue(sessionID, forKey: UdacityApiClient.UserDefaults.SessionID)
            self.setUserValue(expirationDate, forKey: UdacityApiClient.UserDefaults.ExpirationDate)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            block(true, nil)
        })
    }
    
}
