//
//  PersistenceCentral.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 16/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreData

//-----------------------------------------------------
// MARK: - PersistenceCentral
//-----------------------------------------------------

class PersistenceCentral {
 
    //-----------------------------------------------------
    // MARK: - Properties -
    //-----------------------------------------------------
    
    // MARK: Shared Instance
    
    /**
     *  This class variable provides an easy way to get access
     *  to a shared instance of the CoreDataStackManager class.
     */
    class func sharedInstance() -> PersistenceCentral {
        struct Static {
            static let instance = PersistenceCentral()
        }
        
        return Static.instance
    }
    
    // MARK: Private
    
    private static let coreDataStackManager = CoreDataStackManager.sharedInstance()
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Pin.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.createdAt.rawValue, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: PersistenceCentral.coreDataStackManager.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        // Use try! because an error is returned if the fetch request specified doesn't include
        // a sort descriptor that uses sectionNameKeyPath.
        _ = try! fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    //-----------------------------------------------------
    // MARK: - Core Data Convenience
    //-----------------------------------------------------
    
    func getAllPins() -> [Pin] {
        return fetchedResultsController.fetchedObjects as? [Pin] ?? [Pin]()
    }
    
}
