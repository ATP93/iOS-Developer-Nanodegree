//
//  MemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Ivan Magda on 12.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------------
// MARK: - MemeCollectionViewCell: UICollectionViewCell
//------------------------------------------------------

class MemeCollectionViewCell: UICollectionViewCell {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var memedImageView: UIImageView!
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "MemeCollectionViewCell"
    
    static let defaultHeight: CGFloat = 240.0
    
}
