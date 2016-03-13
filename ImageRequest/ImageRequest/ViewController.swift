//
//  ViewController.swift
//  ImageRequest
//
//  Created by Иван Магда on 13.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageURL = NSURL(string: Constants.CatURL)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            if let error = error {
                print("Downloading image failed. Error: \(error.localizedDescription)")
            } else if let data = data {
                let donwloadedImage = UIImage(data: data)
                
                performUIUpdatesOnMain {
                    self.imageView.image = donwloadedImage
                }
            }
        }
        
        task.resume()
    }

}

