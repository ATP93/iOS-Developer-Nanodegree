//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by Ivan Magda on 17.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//--------------------------------------------
// MARK: - MemeTableViewCell: UITableViewCell
//--------------------------------------------

class MemeTableViewCell: UITableViewCell {

    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var memedImageView: UIImageView!
    @IBOutlet weak var memeTextLabel: UILabel!
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "MemeTableViewCell"

    static let defaultHeight: CGFloat = 88.0
    
}
