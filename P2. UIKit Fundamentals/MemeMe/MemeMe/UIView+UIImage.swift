//
//  UIView+UIImage.swift
//  MemeMe
//
//  Created by Ivan Magda on 12.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Creates a UIImage from view hierarchy.
    func generateImage() -> UIImage {
        // render view to an image
        UIGraphicsBeginImageContext(frame.size)
        drawViewHierarchyInRect(frame, afterScreenUpdates: true)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
