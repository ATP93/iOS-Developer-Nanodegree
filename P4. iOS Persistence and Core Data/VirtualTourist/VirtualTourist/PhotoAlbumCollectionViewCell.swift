//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 17/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------------------
// MARK: - PhotoAlbumCollectionViewCell: UICollectionViewCell
//------------------------------------------------------------

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
 
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    // MARK: Static
    static let reuseIdentifier = "PhotoAlbumCollectionViewCell"
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
