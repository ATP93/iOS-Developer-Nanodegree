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
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
