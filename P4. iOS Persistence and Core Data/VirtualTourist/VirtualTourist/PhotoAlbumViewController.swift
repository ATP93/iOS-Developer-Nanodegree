//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 16/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import MapKit
import CoreData

//---------------------------------------------------------
// MARK: - PhotoAlbumViewController: UIViewController
//---------------------------------------------------------

class PhotoAlbumViewController: UIViewController {
    
    //-----------------------------------------------------
    // MARK: - Properties -
    //-----------------------------------------------------
    
    // MARK: Public
    var pin: Pin!
    var coreDataStackManager: CoreDataStackManager!
    var flickrApiClient: FlickrApiClient!
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionBarButtonItem: UIBarButtonItem!
    
    // MARK: Private
    private static let collectionViewNumColumns = 3
    private static let collectionViewSectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    private static let itemsInPhotoCollecton = collectionViewNumColumns * 7
    
    private var photos: [Photo]?
    
    //-----------------------------------------------------
    // MARK: - View Life Cycle -
    //-----------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(pin != nil && coreDataStackManager != nil && flickrApiClient != nil)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        configureMapView()
        
        if let toolbarHeight = navigationController?.toolbar.frame.size.height {
            collectionView.contentInset.bottom = toolbarHeight
        }
        
        if pin.photos.count == 0 {
            UIUtils.showNetworkActivityIndicator()
            flickrApiClient.fetchPhotosByCoordinate(pin.coordinate, itemsPerPage: PhotoAlbumViewController.itemsInPhotoCollecton) { [unowned self] (photosJson, error) in
                UIUtils.hideNetworkActivityIndicator()
                guard error == nil else {
                    self.presentAlertWithTitle("An error occured", message: error!.localizedDescription)
                    return
                }
                
                self.photos = Photo.sanitizedPhotos(photosJson!, parentPin: self.pin, context: self.coreDataStackManager.managedObjectContext)
                self.collectionView.reloadData()
            }
        } else {
            photos = pin.photos
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //-----------------------------------------------------
    // MARK: - Helpers
    //-----------------------------------------------------
    
    private func configureMapView() {
        mapView.addAnnotation(pin)
        let region = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }
    
    //-----------------------------------------------------
    // MARK: - Actions
    //-----------------------------------------------------

    @IBAction func newCollectionDidPressed(sender: AnyObject) {
        print(#function)
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController (UI Functions)
//---------------------------------------------------------------

extension PhotoAlbumViewController {
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDataSource -
//---------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoAlbumCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
        return cell
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDelegate -
//---------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(#function + " at index: \(indexPath.row)")
    }
    
}

//---------------------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDelegateFlowLayout
//---------------------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let delegateFlowLayout = collectionView.delegate as! UICollectionViewDelegateFlowLayout
        
        let screenWidth = UIUtils.screenSize().width
        let sectionInsets = delegateFlowLayout.collectionView!(collectionView, layout: flowLayout, insetForSectionAtIndex: indexPath.section)
        
        let itemSpacing = delegateFlowLayout.collectionView!(collectionView, layout: flowLayout, minimumInteritemSpacingForSectionAtIndex: indexPath.section)
        var totalItemsSpacing = itemSpacing * (CGFloat(PhotoAlbumViewController.collectionViewNumColumns - 1))
        totalItemsSpacing = max(itemSpacing, totalItemsSpacing)
        
        let width = (screenWidth - (sectionInsets.left + sectionInsets.right + totalItemsSpacing)) / CGFloat(PhotoAlbumViewController.collectionViewNumColumns)
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return PhotoAlbumViewController.collectionViewSectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4.0
    }
    
}
