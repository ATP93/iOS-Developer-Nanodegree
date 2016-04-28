//
//  UdacityApiClientConvenience.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-------------------------------------
// MARK: Typealiases
//-------------------------------------

typealias UdacityConvenientCompletionHandler = (success: Bool, error: NSError?) -> Void
typealias UdacityUserCompletionHandler = (user: User?, error: NSError?) -> Void

//--------------------------------------------------------
// MARK: - UdacityApiClient (Convenient Resource Methods)
//--------------------------------------------------------

extension UdacityApiClient {
    
    //----------------------------------------------------
    // MARK: Authentication (POST) method
    //----------------------------------------------------
    
    func authenticateWithUsername(username: String, password: String, completionHandler: UdacityConvenientCompletionHandler) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        dataTaskForPostMethod(UdacityApiClient.Methods.AuthenticationSession, parameters: nil, jsonBody: jsonBody, completionHandler: { (jsonObject, error) in
            func sendError(error: String) {
                self.debugLog(error)
                let error = NSError(
                    domain: UdacityApiClient.UserAuthDomain,
                    code: UdacityApiClient.UserAuthErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : error]
                )
                completionHandler(success: false, error: error)
            }
            
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let json = jsonObject else {
                sendError("Empty response")
                return
            }
            
            guard let session = json[UdacityApiClient.JSONResponseKeys.Session] as? JSONDictionary,
                  let sessionId = session[UdacityApiClient.JSONResponseKeys.SessionID] as? String,
                  let expirationDate = session[UdacityApiClient.JSONResponseKeys.ExpirationDate] as? String else {
                    sendError("Could not find key: \(UdacityApiClient.JSONResponseKeys.SessionID)")
                    return
            }
            
            self.userSession.sessionId = sessionId
            self.userSession.expirationDate = expirationDate
            
            guard let account = json[UdacityApiClient.JSONResponseKeys.Account] as? JSONDictionary,
                  let userId = account[UdacityApiClient.JSONResponseKeys.UserID] as? String else {
                    sendError("Could not find key: \(UdacityApiClient.JSONResponseKeys.UserID)")
                    return
            }
            self.userSession.userId = userId
            
            completionHandler(success: true, error: nil)
        })
    }
    
    //----------------------------------------------------
    // MARK: Logging Out (DELETE) method
    //----------------------------------------------------
    
    func logOut(completionHandler: UdacityConvenientCompletionHandler) {
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        dataTaskForDeleteMethod(UdacityApiClient.Methods.LoggingOut, parameters: nil, headerFields: ["X-XSRF-TOKEN": xsrfCookie?.value]) { (result, error) in
            func sendError(error: String) {
                self.debugLog(error)
                let error = NSError(
                    domain: UdacityApiClient.UserLogoutDomain,
                    code: UdacityApiClient.UserLogoutErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : error]
                )
                completionHandler(success: false, error: error)
            }
            
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let _ = result else {
                sendError("Empty response")
                return
            }
            UdacityUserSession.logout()
            
            completionHandler(success: true, error: nil)
        }
    }
    
    func getPublicUserData(userId: String, completionHandler: UdacityUserCompletionHandler) {
        var mutableMethod: String = Methods.UserData
        mutableMethod = subtituteKeyInMethod(mutableMethod,
                                             key: URLKeys.UserID,
                                             value: UdacityApiClient.sharedInstance.userSession.userId!)!
        
        dataTaskForGetMethod(mutableMethod, parameters: nil) { (result, error) in
            func sendError(error: String) {
                self.debugLog(error)
                let error = NSError(
                    domain: UdacityApiClient.GetPublicUserDataDomain,
                    code: UdacityApiClient.GetPublicUserDataErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : error]
                )
                completionHandler(user: nil, error: error)
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
            
            completionHandler(user: user, error: nil)
        }
    }
    
}
