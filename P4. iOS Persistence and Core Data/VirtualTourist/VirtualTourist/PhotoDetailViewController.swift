//
//  PhotoDetailViewController.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 18/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//---------------------------------------------------------
// MARK: - PhotoDetailViewController: UIViewController -
//---------------------------------------------------------

class PhotoDetailViewController: UIViewController {
    
    //-----------------------------------------------------
    // MARK: - Properties
    //-----------------------------------------------------
    
    // MARK: Public
    var photo: Photo!
    var coreDataStackManager: CoreDataStackManager!
    var flickrApiClient: FlickrApiClient!
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    //-----------------------------------------------------
    // MARK: - View Life Cycle
    //-----------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(photo != nil && coreDataStackManager != nil && flickrApiClient != nil)
        setup()
    }
    
    //-----------------------------------------------------
    // MARK: - Helpers
    //-----------------------------------------------------
    
    private func setup() {
        label.text = (photo.title != nil ? photo.title! : nil)
        imageView.image = nil
        
        let medium = photo.photoData.medium
        if let data = medium.data {
            guard let image = UIImage(data: data) else {
                presentAlertWithTitle("Error", message: "Could't present image. Failed to decode data.")
                return
            }
            
            imageView.image = image
        } else {
            guard let url = NSURL(string: medium.path) else {
                presentAlertWithTitle("Error", message: "Could't download image data. Bad resource path.")
                return
            }
            
            activityIndicator.startAnimating()
            flickrApiClient.loadImageData(url) { [unowned self] (imageData, error) in
                self.activityIndicator.stopAnimating()
                
                guard error == nil else {
                    self.presentAlertWithTitle("Error", message: "Failed to download an image. \(error!.localizedDescription).")
                    return
                }
                
                medium.data = imageData!
                self.coreDataStackManager.saveContext()
                
                guard let image = UIImage(data: imageData!) else {
                    self.presentAlertWithTitle("Error", message: "Could't present image. Failed to decode data.")
                    return
                }
                
                self.imageView.image = image
            }
        }
    }

}

//---------------------------------------------------------------
// MARK: - PhotoDetailViewController (UI Functions)
//---------------------------------------------------------------

extension PhotoDetailViewController {
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
