//
//  UdacityConstants.swift
//  On the Map
//
//  Created by Ivan Magda on 21.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

extension UdacityApiClient {
    
    // MARK: Constant
    struct Constant {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: User
        static let UserData = "/users/{id}"
        
        // MARK: Authentication
        static let LoggingOut = "/session"
        static let AuthenticationSession = "/session"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let Facebook = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Account
        static let Account = "account"
        static let Register = "registered"
        static let UserID = "key"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let Nickname = "nickname"
        static let Email = "email"
        static let EmailAddres = "address"
        
        // MARK: Session
        static let Session = "session"
        static let SessionID = "id"
        static let ExpirationDate = "expiration"
        
    }
    
}