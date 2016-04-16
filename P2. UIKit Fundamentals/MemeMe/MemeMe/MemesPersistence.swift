//
//  MemesPersistence.swift
//  MemeMe
//
//  Created by Ivan Magda on 12.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-----------------------------------------
// MARK: Types
//-----------------------------------------

private enum CoderKey: String {
    case Memes
}

//-----------------------------------------
// MARK: - MemesPersistence
//-----------------------------------------

class MemesPersistence {
    
    //-------------------------------------
    // MARK: Properties
    //-------------------------------------
    
    var memes: [Meme]!
    
    //-------------------------------------
    // MARK: Init
    //-------------------------------------
    
    init() {
        loadMemes()
    }
    
    //-------------------------------------
    // MARK: Save/Load
    //-------------------------------------
    
    func saveMemes() -> Bool {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(memes, forKey: CoderKey.Memes.rawValue)
        archiver.finishEncoding()
        
        do {
            try data.writeToFile(dataFilePath(), options: .DataWritingAtomic)
        } catch let e as NSError {
            print("Failed to save memes to the documents directory. Error: \(e.localizedDescription)")
            return false
        }
        
        return true
    }
    
    private func loadMemes() {
        func instantiateMemesArray() {
            memes = [Meme]()
        }
        
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            guard let data = NSData(contentsOfFile: path) else {
                instantiateMemesArray()
                return
            }
            
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            guard let memes = unarchiver.decodeObjectForKey(CoderKey.Memes.rawValue) as? [Meme] else {
                instantiateMemesArray()
                return
            }
            
            self.memes = memes
        } else {
            instantiateMemesArray()
        }
    }
    
    //-------------------------------------
    // MARK: Paths
    //-------------------------------------
    
    private func documentsDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }
    
    private func dataFilePath() -> String {
        return (documentsDirectory() as NSString)
            .stringByAppendingPathComponent("\(CoderKey.Memes.rawValue).plist")
    }
    
}