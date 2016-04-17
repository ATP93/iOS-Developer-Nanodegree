//
//  MemeTableViewEmptyDataSourceCell.swift
//  MemeMe
//
//  Created by Ivan Magda on 17.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-----------------------------------------------------------
// MARK: - MemeTableViewEmptyDataSourceCell: UITableViewCell
//-----------------------------------------------------------

class MemeTableViewEmptyDataSourceCell: UITableViewCell {

    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var createMemeButton: BorderedButton!
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "MemeEmptyDataSourceTableViewCell"
    
    static let defaultHeight: CGFloat = 160.0

}
