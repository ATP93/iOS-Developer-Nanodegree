//
//  BorderedButton.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - BorderedButton: Button

class BorderedButton: UIButton {

    // MARK: Properties
    
    let borderedButtonCornerRadius: CGFloat = 4.0
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        themeBorderedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeBorderedButton()
    }
    
    private func themeBorderedButton() {
        layer.masksToBounds = true
        layer.cornerRadius = borderedButtonCornerRadius
    }
    
}