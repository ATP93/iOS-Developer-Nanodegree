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

class PersistenceCentral: NSObject {
 
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
    
    // MARK: Public
    
    var pins = [Pin]()
    
    // MARK: Private
    
    private static let coreDataStackManager = CoreDataStackManager.sharedInstance()
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Pin.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.createdAt.rawValue, ascending: false)]
        fetchRequest.returnsObjectsAsFaults = false
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: PersistenceCentral.coreDataStackManager.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //-----------------------------------------------------
    // MARK: - Init
    //-----------------------------------------------------
    
    override init() {
        super.init()
        
        // Use try! because an error is returned if the fetch request specified doesn't include
        // a sort descriptor that uses sectionNameKeyPath.
        _ = try! fetchedResultsController.performFetch()
        updatePins()
    }
    
}

//-----------------------------------------------------------------
// MARK: - PersistenceCentral: NSFetchedResultsControllerDelegate -
//-----------------------------------------------------------------

extension PersistenceCentral: NSFetchedResultsControllerDelegate {

    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        updatePins()
    }
    
    // MARK: Helpers
    
    private func updatePins() {
        pins = fetchedResultsController.fetchedObjects as? [Pin] ?? [Pin]()
    }
    
}

