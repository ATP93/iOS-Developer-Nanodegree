/**
 * Copyright (c) 2017 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

// MARK: Types

private enum CoderKey: String {
    case topText
    case bottomText
    case originalImage
    case memedImage
}

// MARK: - Meme

class Meme: NSObject, NSCoding {
  
    // MARK: Properties
    
    var topText: String
    var bottomText: String
    
    var originalImage: UIImage
    var memedImage: UIImage
  
    // MARK: Init
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }

    // MARK: - Meme: NSCoding Support
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(topText, forKey: CoderKey.topText.rawValue)
        aCoder.encode(bottomText, forKey: CoderKey.bottomText.rawValue)
        aCoder.encode(originalImage, forKey: CoderKey.originalImage.rawValue)
        aCoder.encode(memedImage, forKey: CoderKey.memedImage.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let topText = aDecoder.decodeObject(forKey: CoderKey.topText.rawValue) as? String,
            let bottomText = aDecoder.decodeObject(forKey: CoderKey.bottomText.rawValue) as? String,
            let originalImage = aDecoder.decodeObject(forKey: CoderKey.originalImage.rawValue) as? UIImage,
            let memedImage = aDecoder.decodeObject(forKey: CoderKey.memedImage.rawValue) as? UIImage else {
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
