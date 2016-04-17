//
//  MemeCollectionViewEmptyDataSourceCell.swift
//  MemeMe
//
//  Created by Ivan Magda on 16.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//---------------------------------------------------------------------
// MARK: - MemeCollectionViewEmptyDataSourceCell: UICollectionViewCell
//---------------------------------------------------------------------

class MemeCollectionViewEmptyDataSourceCell: UICollectionViewCell {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var createMemeButton: BorderedButton!
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "EmptyDataSourceCell"
    
    static let defaultHeight: CGFloat = 124.0

}
