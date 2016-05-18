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
        backgroundColor = backgroundColor?.colorWithAlphaComponent(0.85)
    }
    
}
