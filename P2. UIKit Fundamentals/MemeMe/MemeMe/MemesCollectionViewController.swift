//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ivan Magda on 12.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-------------------------------------------------------------------
// MARK: Types
//-------------------------------------------------------------------

private enum SegueIdentifier: String {
    case CreateMeme
    case ShowMeme
}

//-------------------------------------------------------------------
// MARK: - MemesCollectionViewController: UICollectionViewController
//-------------------------------------------------------------------

class MemesCollectionViewController: UICollectionViewController {

    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //--------------------------------------------
    // MARK: Navigation
    //--------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch SegueIdentifier(rawValue: segue.identifier!)! {
        case .CreateMeme:
            print("create meme")
            let controller = segue.destinationViewController as! MemeEditorViewController
            controller.title = NSLocalizedString("Create", comment: "DetailMemeController create meme title")
        case .ShowMeme:
            print("show meme")
            let controller = segue.destinationViewController as! MemeEditorViewController
            controller.title = NSLocalizedString("Detail", comment: "DetailMemeController detail meme title")
        }
    }

    //--------------------------------------------
    // MARK: UICollectionViewDataSource
    //--------------------------------------------

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MemeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.memeLabel.text = "Label \(indexPath.row + 1)"
    
        return cell
    }

}
