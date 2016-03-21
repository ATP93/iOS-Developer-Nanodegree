//
//  FirstViewController.swift
//  On the Map
//
//  Created by Ivan Magda on 20.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------
// MARK: - MapViewController: UIViewController
//------------------------------------------------

class MapViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ParseApiClient.sharedInstance.getStudentLocationsWithCompletionHandler { (locations, error) in
            performOnMain {
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let locations = locations {
                        print("Successfully fetched \(locations.count) users locations.")
                    }
                }
            }
        }
    }
    
    
}

