//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 16/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import MapKit

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
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //-----------------------------------------------------
    // MARK: - View Life Cycle -
    //-----------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(pin != nil && coreDataStackManager != nil)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        configureMapView()
    }
    
    //-----------------------------------------------------
    // MARK: - Helpers
    //-----------------------------------------------------
    
    private func configureMapView() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }

}

//---------------------------------------------------------------
// MARK: - PhotoAlbumViewController: UICollectionViewDataSource -
//---------------------------------------------------------------

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
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
