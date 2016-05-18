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
// MARK: - Types
//---------------------------------------------------------

// MARK: UIState
private enum UIState {
    case Default
    case Download
    case DoneDownloading
}

//---------------------------------------------------------
// MARK: - PhotoAlbumViewController: UIViewController -
//---------------------------------------------------------

class PhotoAlbumViewController: UIViewController {
    
    //-----------------------------------------------------
    // MARK: - Properties
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
    private var temporaryContext: NSManagedObjectContext!
    
    private var photosIndexPathsToRemove = Set<NSIndexPath>()
    
    //-----------------------------------------------------
    // MARK: - View Life Cycle
    //-----------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(pin != nil && coreDataStackManager != nil && flickrApiClient != nil)
        setup()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //-----------------------------------------------------
    // MARK: - Actions
    //-----------------------------------------------------

    @IBAction func newCollectionDidPressed(sender: AnyObject) {
        func presentLoadAlbumAlert(title title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { action in
                self.clearDataSource()
                self.loadAlbumWithPageNumber(1)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        
        print(#function)
        
        // GUARD: Is there an album details?
        guard let album = pin.albumDetails else {
            presentLoadAlbumAlert(title: "Oops", message: "We could't find details about your photo album. Try again to load information?")
            return
        }
        
        let pages = album.pages.integerValue
        guard pages > 0 else {
            presentLoadAlbumAlert(title: "There's no photos 😩", message: "Try again to load?")
            return
        }
        
        var nextPage = album.page.integerValue + 1
        if nextPage > pages {
            nextPage = 1
        }
        
        clearDataSource()
        loadAlbumWithPageNumber(nextPage)
    }
    
    //-----------------------------------------------------
    // MARK: - Helpers
    //-----------------------------------------------------
    
    private func loadAlbumWithPageNumber(page: Int) {
        flickrApiClient.fetchPhotosByCoordinate(pin.coordinate, pageNumber: page, itemsPerPage: PhotoAlbumViewController.itemsInPhotoCollecton) { [unowned self] (albumJSON, photosJson, error) in
            self.setUiState(.DoneDownloading)
            
            // Parse album details and update current album properties if it doesn't exist yet
            // or create one in main context.
            if let albumJSON = albumJSON, let tempAlbum = PhotoAlbumDetails(json: albumJSON, context: self.temporaryContext) {
                if let album = self.pin.albumDetails {
                    album.copyValues(tempAlbum)
                } else {
                    self.pin.albumDetails = PhotoAlbumDetails(album: tempAlbum, context: self.coreDataStackManager.managedObjectContext)
                }
                self.coreDataStackManager.saveContext()
            }
            
            guard error == nil else {
                self.presentAlertWithTitle("An error occured", message: error!.localizedDescription)
                return
            }
            
            self.photos = Photo.sanitizedPhotos(photosJson!, parentPin: self.pin, context: self.coreDataStackManager.managedObjectContext)
            self.coreDataStackManager.saveContext()
            
            self.updateNewCollectionBarButtonEnabledState()
            self.collectionView.reloadData()
        }
    }
    
    private func clearDataSource() {
        pin.deletePhotos(coreDataStackManager.managedObjectContext)
        coreDataStackManager.saveContext()
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController (Setup) -
//---------------------------------------------------------------

extension PhotoAlbumViewController {
    
    private func setup() {
        uiSetup()
        mapViewSetup()
        dataSourceSetup()
    }
    
    private func uiSetup() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let toolbarHeight = navigationController?.toolbar.frame.size.height {
            collectionView.contentInset.bottom = toolbarHeight
        }
        setUiState(.Default)
    }
    
    private func mapViewSetup() {
        mapView.addAnnotation(pin)
        let region = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }
    
    private func dataSourceSetup() {
        temporaryContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = coreDataStackManager.persistentStoreCoordinator
        
        // If a pin does't have any photos, then download images from Flickr.
        // Otherwise photos will be immediately displayed. No new download is needed.
        
        if pin.photos.count == 0 {
            setUiState(.Download)
            loadAlbumWithPageNumber(1)
        } else {
            photos = pin.photos
        }
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController (UI Functions)
//---------------------------------------------------------------

extension PhotoAlbumViewController {
    
    private func setUiState(state: UIState) {
        switch state {
        case .Default:
            updateNewCollectionBarButtonEnabledState()
        case .Download:
            UIUtils.showNetworkActivityIndicator()
            newCollectionBarButtonItem.enabled = false
        case .DoneDownloading:
            UIUtils.hideNetworkActivityIndicator()
            newCollectionBarButtonItem.enabled = true
        }
    }
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func updateNewCollectionBarButtonEnabledState() {
        newCollectionBarButtonItem.enabled = (pin.albumDetails?.pages.integerValue > 0 || pin.photos.count > 0)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoAlbumCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        if photosIndexPathsToRemove.contains(indexPath) {
            cell.setSelectedState(.Selected)
        } else {
            cell.setSelectedState(.NotSelected)
        }
        
        let photo = photos![indexPath.row]
        let thumbnail = photo.photoData.thumbnail
        
        if let data = thumbnail.data {
            cell.activityIndicator.stopAnimating()
            
            guard let image = UIImage(data: data) else {
                return cell
            }
            
            cell.imageView.image = image
        } else {
            guard let url = NSURL(string: thumbnail.path) else {
                return cell
            }
            
            cell.activityIndicator.startAnimating()
            cell.imageView.image = UIImage(named: UIUtils.placeholderImageName)
            
            weak var weakCell: PhotoAlbumCollectionViewCell? = cell
            flickrApiClient.loadImageData(url) { [unowned self] (imageData, error) in
                weakCell?.activityIndicator.stopAnimating()
                
                guard error == nil else {
                    print("Failed to download an thumbnail image. Error: \(error!.localizedDescription)")
                    return
                }
                
                thumbnail.data = imageData!
                self.coreDataStackManager.saveContext()
                
                guard let image = UIImage(data: imageData!) else {
                    return
                }
                
                weakCell?.imageView.image = image
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }
        
        return cell
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDelegate -
//---------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(#function + " at index: \(indexPath.row)")
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoAlbumCollectionViewCell else {
            return
        }
        
        // GUARD: Image already downloaded?
        guard cell.activityIndicator.isAnimating() == false else {
            return
        }
        
        guard photosIndexPathsToRemove.contains(indexPath) == false else {
            photosIndexPathsToRemove.remove(indexPath)
            cell.setSelectedState(.NotSelected)
            return
        }
        
        photosIndexPathsToRemove.insert(indexPath)
        cell.setSelectedState(.Selected)
    }
    
}

//---------------------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDelegateFlowLayout -
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
