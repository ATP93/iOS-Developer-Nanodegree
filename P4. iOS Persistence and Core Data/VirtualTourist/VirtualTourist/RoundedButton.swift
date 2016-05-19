//
//  RoundedButton.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 18/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//---------------------------------------------------
// MARK: - RoundedButton: Button
//---------------------------------------------------

class RoundedButton: UIButton {
    
    //-----------------------------------------------
    // MARK: Properties
    //-----------------------------------------------
    
    private static let colorAlphaComponent: CGFloat = 0.85
    
    //-----------------------------------------------
    // MARK: Init
    //-----------------------------------------------
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        themeRoundedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeRoundedButton()
    }
    
    //-----------------------------------------------
    // MARK: Helpers
    //-----------------------------------------------
    
    private func themeRoundedButton() {
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2.0
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(RoundedButton.colorAlphaComponent).CGColor
        backgroundColor = backgroundColor?.colorWithAlphaComponent(RoundedButton.colorAlphaComponent)
    }
    
}
