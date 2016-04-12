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
    @IBOutlet weak var memeLabel: UILabel!
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "MemeCollectionViewCell"
    
}
