//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Ivan Magda on 14.03.16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        grabImageButton.enabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr() {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters)
        guard let url = NSURL(string: urlString) else {
            print("Failed to build an url. URL: \(urlString)")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            func displayError(error: String) {
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
            }
            
            // Was there an error.
            guard error == nil else {
                displayError("There was an error: \(error!.localizedDescription)")
                return
            }
            
            // Did recieve a successfull 2xx response.
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your requst returned a status code other than 2xx")
                return
            }
            
            // Was there any data returned.
            guard let data = data else {
                displayError("No data was returned!")
                return
            }
            
            // Parse the data.
            let parsedResult: AnyObject!
            do {
                // Serialize the retrieved data into JSON object.
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch let error as NSError {
                print("Failed to parse the retrieved JSON data. Error: \(error.localizedDescription)")
                return
            }
            
            // Did Flickr return an error.
            guard let flickrStatus = parsedResult[Constants.FlickrResponseKeys.Status] as? String where flickrStatus == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flick API returned an error.")
                return
            }
            
            // Are the "photos" and "photo" keys in our result.
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
                let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    displayError("Cannot find keys")
                    return
            }
            
            // Select a random photo.
            let randPhotoIdx = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randPhotoIdx]
            let imageTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                displayError("Cannot find image URL key")
                return
            }
            
            // Load an image.
            if let imageURL = NSURL(string: imageUrlString) {
                if let imageData = NSData(contentsOfURL: imageURL) {
                    performUIUpdatesOnMain {
                        self.photoImageView.image = UIImage(data: imageData)
                        self.photoTitleLabel.text = imageTitle
                        self.setUIEnabled(true)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func escapedParameters(parameters: [String: AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                // Make sure to use String value.
                let stringValue = "\(value)"
                
                // Escape the value string.
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // Append it.
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
    
}