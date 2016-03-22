//
//  User.swift
//  On the Map
//
//  Created by Ivan Magda on 22.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//------------------------------------
// MARK: - StudentLocation
//------------------------------------

struct User {
    
    //------------------------------------
    // MARK: Properties
    //------------------------------------
    
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    //------------------------------------
    // MARK: Initializers
    //------------------------------------
    
    init(id: String, firstName: String, lastName: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
}