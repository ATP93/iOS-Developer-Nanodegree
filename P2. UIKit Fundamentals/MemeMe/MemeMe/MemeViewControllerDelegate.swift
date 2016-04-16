//
//  MemeViewControllerDelegate.swift
//  MemeMe
//
//  Created by Ivan Magda on 16.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//---------------------------------------
// MARK: - MemeViewControllerDelegate
//---------------------------------------

protocol MemeViewControllerDelegate {
    
    func memeViewController(controller: MemeViewController, didDoneOnMemeShare meme: Meme)
    func memeViewController(controller: MemeViewController, didDoneOnMemeEditing meme: Meme)
    func memeViewController(controller: MemeViewController, didSelectRemoveMeme meme: Meme)
}
