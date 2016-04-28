//
//  UdacityUserSession.swift
//  On the Map
//
//  Created by Ivan Magda on 28.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-----------------------------------------
// MARK: - UdacityUserSession
//-----------------------------------------

class UdacityUserSession {

    //-----------------------------------------
    // MARK: Properties
    //-----------------------------------------
    
    var sessionId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaults.SessionId.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaults.SessionId.rawValue)
            synchronize()
        }
    }
    
    var userId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaults.UserId.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaults.UserId.rawValue)
            synchronize()
        }
    }
    
    var expirationDate: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaults.ExpirationDate.rawValue)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaults.ExpirationDate.rawValue)
            synchronize()
        }
    }
    
    var isLoggedIn: Bool {
        return (userId != nil && !userId!.isEmpty)
    }
    
    //-----------------------------------------
    // MARK: Class Functions
    //-----------------------------------------
    
    class func logout() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(UserDefaults.UserId.rawValue)
        defaults.removeObjectForKey(UserDefaults.SessionId.rawValue)
        defaults.removeObjectForKey(UserDefaults.ExpirationDate.rawValue)
        defaults.removeObjectForKey(UserDefaults.CurrentUser.rawValue)
        defaults.synchronize()
    }
    
    //-----------------------------------------
    // MARK: Private
    //-----------------------------------------
    
    private func synchronize() -> Bool {
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}

//-------------------------------------------
// MARK: - UdacityUserSession (UserDefaults)
//-------------------------------------------

extension UdacityUserSession {
    
    enum UserDefaults: String {
        case SessionId = "session_id"
        case UserId = "user_id"
        case ExpirationDate = "expiration_date"
        case CurrentUser = "current_user"
    }
    
}
