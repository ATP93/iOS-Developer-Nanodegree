//
//  User+JSONParselable.swift
//  On the Map
//
//  Created by Ivan Magda on 22.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

extension User: JSONParselable {
    
    static func decode(json: JSONDictionary) -> User? {
        guard
            let id = JSON.string(json, key: UserKey.Id.rawValue),
            let firstName = JSON.string(json, key: UserKey.FirstName.rawValue),
            let lastName = JSON.string(json, key: UserKey.LastName.rawValue),
            let emailDictionary = json[UserKey.EmailDictionary.rawValue] as? JSONDictionary,
            let email = JSON.string(emailDictionary, key: UserKey.EmailAddress.rawValue) else {
            return nil
        }
        
        let user = User(id: id, firstName: firstName, lastName: lastName, email: email)
        
        return user
    }
    
}
