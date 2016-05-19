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
    
    //--------------------------------------------------------
    // MARK: - Types
    //--------------------------------------------------------
    
    enum SelectedState {
        case Selected
        case NotSelected
    }
 
    //--------------------------------------------------------
    // MARK: - Properties
    //--------------------------------------------------------
    
    // MARK: Static
    static let reuseIdentifier = "PhotoAlbumCollectionViewCell"
    private static let selectedColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectedView: UIView!
    
    //--------------------------------------------------------
    // MARK: - Methods
    //--------------------------------------------------------
    
    func setSelectedState(state: SelectedState) {
        switch state {
        case .Selected:
            selectedView.backgroundColor = PhotoAlbumCollectionViewCell.selectedColor
            selectedView.alpha = 1.0
            selectedView.hidden = false
        case .NotSelected:
            selectedView.backgroundColor = .clearColor()
            selectedView.alpha = 0.0
            selectedView.hidden = true
        }
    }
    
}
