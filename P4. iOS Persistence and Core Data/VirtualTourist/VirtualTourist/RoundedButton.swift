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
        themeBorderedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeBorderedButton()
    }
    
    //-----------------------------------------------
    // MARK: Helpers
    //-----------------------------------------------
    
    private func themeBorderedButton() {
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2.0
        backgroundColor = backgroundColor?.colorWithAlphaComponent(0.75)
    }
    
}
