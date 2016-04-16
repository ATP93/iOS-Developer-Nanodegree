//
//  Meme.swift
//  MemeMe
//
//  Created by Ivan Magda on 12.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-----------------------------------------
// MARK: Types
//-----------------------------------------

private enum CoderKey: String {
    case TopText
    case BottomText
    case OriginalImage
    case MemedImage
}

//-----------------------------------------
// MARK: - Meme
//-----------------------------------------

class Meme: NSObject, NSCoding {
    
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

    //-----------------------------------------
    // MARK: - Meme: NSCoding Support
    //-----------------------------------------
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(topText, forKey: CoderKey.TopText.rawValue)
        aCoder.encodeObject(bottomText, forKey: CoderKey.BottomText.rawValue)
        aCoder.encodeObject(originalImage, forKey: CoderKey.OriginalImage.rawValue)
        aCoder.encodeObject(memedImage, forKey: CoderKey.MemedImage.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let topText = aDecoder.decodeObjectForKey(CoderKey.TopText.rawValue) as? String,
            let bottomText = aDecoder.decodeObjectForKey(CoderKey.BottomText.rawValue) as? String,
            let originalImage = aDecoder.decodeObjectForKey(CoderKey.OriginalImage.rawValue) as? UIImage,
            let memedImage = aDecoder.decodeObjectForKey(CoderKey.MemedImage.rawValue) as? UIImage else {
                return nil
        }
        
        self.init(
            topText: topText,
            bottomText: bottomText,
            originalImage: originalImage,
            memedImage: memedImage
        )
    }
    
}
