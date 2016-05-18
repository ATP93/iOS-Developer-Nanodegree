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
    case Normal
    case Downloading
    case DoneWithDownloading
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
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    // MARK: Private
    private static let collectionViewNumColumns = 3
    private static let collectionViewSectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    private static let itemsInPhotoCollecton = collectionViewNumColumns * 7
    
    private var temporaryContext: NSManagedObjectContext!
    private var selectedIndexPath = Set<NSIndexPath>()
    
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        updateBarButtonItemTitle(animated: animated)
        updateBarButtonItemEnabledState()
        
        if !editing && selectedIndexPath.count > 0 {
            removeSelectedPictures()
        }
    }
    
    //-----------------------------------------------------
    // MARK: - Actions
    //-----------------------------------------------------

    @IBAction func barButtonItemDidPressed(sender: AnyObject) {
        if editing {
            setEditing(false, animated: true)
        } else {
            loadNewCollection()
        }
    }
    
    //-----------------------------------------------------
    // MARK: - Helpers
    //-----------------------------------------------------
    
    private func removeSelectedPictures() {
        selectedIndexPath.forEach {
            coreDataStackManager.managedObjectContext.deleteObject(pin.photos[$0.row])
            coreDataStackManager.saveContext()
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItemsAtIndexPaths(Array(self.selectedIndexPath))
            }, completion: { finished in
                if finished {
                    self.selectedIndexPath.removeAll()
                }
        })
    }
    
    private func loadNewCollection() {
        func presentLoadAlbumAlert(title title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { action in
                self.clearDataSource()
                self.loadAlbumWithPageNumber(1)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        
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
    
    private func loadAlbumWithPageNumber(page: Int) {
        setUIState(.Downloading)
        flickrApiClient.fetchPhotosByCoordinate(pin.coordinate, pageNumber: page, itemsPerPage: PhotoAlbumViewController.itemsInPhotoCollecton) { [unowned self] (albumJSON, photosJson, error) in
            self.setUIState(.DoneWithDownloading)
            
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
            
            let _ = Photo.sanitizedPhotos(photosJson!, parentPin: self.pin, context: self.coreDataStackManager.managedObjectContext)
            self.coreDataStackManager.saveContext()
            
            self.updateBarButtonItemEnabledState()
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
        setUIState(.Normal)
        
        navigationItem.rightBarButtonItem = editButtonItem()
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
            setUIState(.Downloading)
            loadAlbumWithPageNumber(1)
        }
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController (UI Functions)
//---------------------------------------------------------------

extension PhotoAlbumViewController {
    
    private func setUIState(state: UIState) {
        switch state {
        case .Normal:
            updateBarButtonItem()
        case .Downloading:
            UIUtils.showNetworkActivityIndicator()
            barButtonItem.enabled = false
        case .DoneWithDownloading:
            UIUtils.hideNetworkActivityIndicator()
            barButtonItem.enabled = true
        }
    }
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func updateBarButtonItem() {
        updateBarButtonItemEnabledState()
        updateBarButtonItemTitle()
    }
    
    private func updateBarButtonItemEnabledState() {
        if editing {
            barButtonItem.enabled = selectedIndexPath.count > 0
        } else {
            barButtonItem.enabled = (pin.albumDetails?.pages.integerValue > 0 || pin.photos.count > 0)
        }
    }
    
    private func updateBarButtonItemTitle(animated animated: Bool = false) {
        let newTitle = (editing == true ? "Remove Selected Pictures" : "New Collection")
        if animated {
            UIView.animateWithDuration(0.75) {
                self.barButtonItem.title = newTitle
            }
        } else {
            barButtonItem.title = newTitle
        }
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDataSource -
//---------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoAlbumCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: Helpers
    
    private func configureCell(cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        if selectedIndexPath.contains(indexPath) {
            cell.setSelectedState(.Selected)
        } else {
            cell.setSelectedState(.NotSelected)
        }
        
        let photo = pin.photos[indexPath.row]
        let thumbnail = photo.photoData.thumbnail
        
        if let data = thumbnail.data {
            cell.activityIndicator.stopAnimating()
            
            guard let image = UIImage(data: data) else {
                return
            }
            
            cell.imageView.image = image
        } else {
            guard let url = NSURL(string: thumbnail.path) else {
                return
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
    }
    
}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDelegate -
//---------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(#function + " at index: \(indexPath.row)")
        
        // GUARD: In editing mode?
        guard editing == true else {
            return
        }
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoAlbumCollectionViewCell else {
            return
        }
        
        // GUARD: Image already downloaded?
        guard cell.activityIndicator.isAnimating() == false else {
            return
        }
        
        guard selectedIndexPath.contains(indexPath) == false else {
            selectedIndexPath.remove(indexPath)
            cell.setSelectedState(.NotSelected)
            updateBarButtonItemEnabledState()
            return
        }
        
        selectedIndexPath.insert(indexPath)
        
        cell.setSelectedState(.Selected)
        updateBarButtonItemEnabledState()
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
