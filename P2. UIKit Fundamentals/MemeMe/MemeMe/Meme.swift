//
//  Meme.swift
//  MemeMe
//
//  Created by Ivan Magda on 12.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-----------------------------------------
// MARK: - Meme
//-----------------------------------------

class Meme {
    
    //-------------------------------------
    // MARK: Properties
    //-------------------------------------
    
    var topText: String
    var bottomText: String
    
    var originalImage: UIImage
    var memedImage: UIImage
    
    //-------------------------------------
    // MARK: Init
    //-------------------------------------
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
    
}
