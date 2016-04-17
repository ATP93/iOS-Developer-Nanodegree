//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Ivan Magda on 17.04.16.
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
// MARK: - MemesTableViewController: UITableViewController
//-------------------------------------------------------------------

class MemesTableViewController: UITableViewController {
    
    //--------------------------------------------
    // MARK: Properties
    //--------------------------------------------
    
    var memesPersistence: MemesPersistence!
    
    private var isEmptyDataSource: Bool {
        get {
            return memesPersistence.memes.count == 0
        }
    }
    
    //--------------------------------------------
    // MARK: View Life Cycle
    //--------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(memesPersistence != nil)
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
            
            guard let selectedCell = sender as? MemeTableViewCell,
                let indexPath = tableView.indexPathForCell(selectedCell) else {
                    return
            }
            
            controller.meme = memesPersistence.memes[indexPath.row]
        }
    }

    //--------------------------------------------
    // MARK: - UITableViewDataSource
    //--------------------------------------------

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isEmptyDataSource ? 1 : memesPersistence.memes.count)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isEmptyDataSource {
            let cell = tableView.dequeueReusableCellWithIdentifier(MemeTableViewEmptyDataSourceCell.reuseIdentifier, forIndexPath: indexPath) as! MemeTableViewEmptyDataSourceCell
            cell.createMemeButton.addTarget(self, action: #selector(MemesTableViewController.createMeme), forControlEvents: .TouchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(MemeTableViewCell.reuseIdentifier) as! MemeTableViewCell
            
            let meme = memesPersistence.memes[indexPath.row]
            cell.memedImageView.image = meme.memedImage
            cell.memeTextLabel.text = "\(meme.topText) ᛫᛫᛫ \(meme.bottomText)"
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (isEmptyDataSource
            ? MemeTableViewEmptyDataSourceCell.defaultHeight
            : MemeTableViewCell.defaultHeight)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !isEmptyDataSource
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            memesPersistence.memes.removeAtIndex(indexPath.row)
            memesPersistence.saveMemes()
            
            if isEmptyDataSource {
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            } else {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    //--------------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------------
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return (isEmptyDataSource ? nil : indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //--------------------------------------------
    // MARK: Actions
    //--------------------------------------------
    
    func createMeme() {
        performSegueWithIdentifier(SegueIdentifier.CreateMeme.rawValue, sender: self)
    }
    
}

//-------------------------------------------------------------------
// MARK: - MemesTableViewController: MemeViewControllerDelegate
//-------------------------------------------------------------------

extension MemesTableViewController: MemeViewControllerDelegate {
    
    func memeViewController(controller: MemeViewController, didDoneOnMemeShare meme: Meme) {
        if controller.presentationType == MemeViewControllerPresentationType.CreateMeme {
            memesPersistence.memes.append(meme)
            memesPersistence.saveMemes()
            tableView.reloadData()
        }
    }
    
    func memeViewController(controller: MemeViewController, didDoneOnMemeEditing meme: Meme) {
        memesPersistence.saveMemes()
        tableView.reloadData()
    }
    
    func memeViewController(controller: MemeViewController, didSelectRemoveMeme meme: Meme) {
        let index = memesPersistence.memes.indexOf(meme)!
        memesPersistence.memes.removeAtIndex(index)
        memesPersistence.saveMemes()
        tableView.reloadData()
    }
    
}
