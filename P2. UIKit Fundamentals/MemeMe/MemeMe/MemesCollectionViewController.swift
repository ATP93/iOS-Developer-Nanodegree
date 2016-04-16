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
    // MARK: Properties
    //--------------------------------------------
    
    var memesPersistence: MemesPersistence!

    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(memesPersistence != nil)
    }

    //--------------------------------------------
    // MARK: Navigation
    //--------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch SegueIdentifier(rawValue: segue.identifier!)! {
        case .CreateMeme:
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! MemeViewController
            controller.title = NSLocalizedString("Create", comment: "DetailMemeController create meme title")
            controller.presentationType = .CreateMeme
            controller.delegate = self
        case .ShowMeme:
            let controller = segue.destinationViewController as! MemeViewController
            controller.title = NSLocalizedString("Detail", comment: "DetailMemeController detail meme title")
            controller.presentationType = .ShowMeme
            controller.delegate = self
            
            guard let selectedCell = sender as? MemeCollectionViewCell,
                let indexPath = collectionView?.indexPathForCell(selectedCell) else {
                    return
            }
            
            controller.meme = memesPersistence.memes[indexPath.row]
        }
    }

    //--------------------------------------------
    // MARK: UICollectionViewDataSource
    //--------------------------------------------

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memesPersistence.memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let meme = memesPersistence.memes[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MemeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.memedImageView.image = meme.memedImage
        cell.memeLabel.text = "\(meme.topText), \(meme.bottomText)"
    
        return cell
    }

}

//-------------------------------------------------------------------
// MARK: - MemesCollectionViewController: MemeViewControllerDelegate
//-------------------------------------------------------------------

extension MemesCollectionViewController: MemeViewControllerDelegate {
    
    func memeViewController(controller: MemeViewController, didDoneOnMemeShare meme: Meme) {
        memesPersistence.memes.append(meme)
        memesPersistence.saveMemes()
        collectionView?.reloadData()
    }
    
    func memeViewController(controller: MemeViewController, didDoneOnMemeEditing meme: Meme) {
        memesPersistence.saveMemes()
        collectionView?.reloadData()
    }
    
    func memeViewController(controller: MemeViewController, didSelectRemoveMeme meme: Meme) {
        let index = memesPersistence.memes.indexOf(meme)!
        memesPersistence.memes.removeAtIndex(index)
        memesPersistence.saveMemes()
        collectionView?.reloadData()
    }
}
