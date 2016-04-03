//
//  ViewController.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var phraseSearchButton: UIButton!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latLonSearchButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phraseTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: Constants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: Constants.Selectors.KeyboardDidHide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Search Actions
    
    @IBAction func searchByPhrase(sender: AnyObject) {
        userDidTapView(self)
        setUIEnabled(false)
        
        if !phraseTextField.text!.isEmpty {
            photoTitleLabel.text = "Searching..."
            
            var methodParameters = getBaseMethodParameters()
            
            if let phraseText = phraseTextField.text {
                methodParameters[Constants.FlickrParameterKeys.Text] = phraseText
            }
            
            displayImageFromFlickrBySearch(methodParameters)
        } else {
            setUIEnabled(true)
            photoTitleLabel.text = "Phrase Empty."
        }
    }
    
    @IBAction func searchByLatLon(sender: AnyObject) {
        userDidTapView(self)
        setUIEnabled(false)
        
        if isTextFieldValid(latitudeTextField, forRange: Constants.Flickr.SearchLatRange) && isTextFieldValid(longitudeTextField, forRange: Constants.Flickr.SearchLonRange) {
            photoTitleLabel.text = "Searching..."
            
            var methodParameters = getBaseMethodParameters()
            methodParameters[Constants.FlickrParameterKeys.BoundingBox] = bboxString()
            
            displayImageFromFlickrBySearch(methodParameters)
        } else {
            setUIEnabled(true)
            photoTitleLabel.text = "Lat should be [-90, 90].\nLon should be [-180, 180]."
        }
    }
    
    private func getBaseMethodParameters() -> [String: String] {
        return [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    private func bboxString() -> String {
        guard let latitude = Double(latitudeTextField.text!),
            let longitude = Double(longitudeTextField.text!) else {
                print("There is no latitude of longitude passed by the user.")
                return "0,0,0,0"
        }
        
        let minLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.start)
        let minLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.start)
        
        let maxLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.end)
        let maxLan = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.end)
        
        return "\(minLon),\(minLat),\(maxLon),\(maxLan)"
    }
    
    // MARK: Flickr API
    
    /// Returns number of pages for a photo search.
    private func numberOfPagesForFlickrPhotoSearch(param methodParameters: [String: AnyObject], completionHandler: (Int, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func failed() {
                completionHandler(0, error)
            }
            
            guard error == nil else {
                failed()
                return
            }
            
            // Did recieve a successfull 2xx response.
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                failed()
                return
            }
            
            // Was there any data returned.
            guard let data = data else {
                failed()
                return
            }
            
            let parseResult: AnyObject!
            do {
                parseResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                failed()
                return
            }
            
            guard let photosDictionary = parseResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
                let numberOfPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    failed()
                    return
            }
            
            completionHandler(numberOfPages, nil)
        }
        
        task.resume()
    }
    
    /// Retrieve and display a random photo from a random page.
    private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject]) {
        numberOfPagesForFlickrPhotoSearch(param: methodParameters) { [weak self] (pages, error) in
            // Select a random photo.
            let pageLimit = min(pages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            var parameters = methodParameters
            parameters[Constants.FlickrParameterKeys.Page] = randomPage
            
            // Start a request.
            let session = NSURLSession.sharedSession()
            let request = NSURLRequest(URL: self!.flickrURLFromParameters(parameters))
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                /// If an error occured, print the error and re-enable the UI.
                func displayError(error: String) {
                    print(error)
                    print("URL at time of error: \(request.URL!)")
                    performUIUpdatesOnMain {
                        self?.setUIEnabled(true)
                        self?.photoTitleLabel.text = "No photo returned. Try again."
                        self?.photoImageView.image = nil
                    }
                }
                
                // Check for error.
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
                } catch let e as NSError {
                    print("Failed to parse the retrieved JSON data. Error: \(e.localizedDescription)")
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
                        displayError("Cannot find 'photos' or 'photo' keys!")
                        return
                }
                
                if photoArray.count == 0 {
                    displayError("No photo found. Try again.")
                    return
                } else {
                    // Select a random photo.
                    let randPhotoIdx = Int(arc4random_uniform(UInt32(photoArray.count)))
                    let photoDictionary = photoArray[randPhotoIdx]
                    let imageTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                    
                    guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find 'url_m' key")
                        return
                    }
                    
                    // Load an image.
                    if let imageURL = NSURL(string: imageUrlString) {
                        if let imageData = NSData(contentsOfURL: imageURL) {
                            performUIUpdatesOnMain {
                                self?.setUIEnabled(true)
                                self?.photoImageView.image = UIImage(data: imageData)
                                self?.photoTitleLabel.text = imageTitle ?? "(Untitled)"
                            }
                        } else {
                            displayError("Image does't exist.")
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
}

// MARK: - ViewController: UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(phraseTextField)
        resignIfFirstResponder(latitudeTextField)
        resignIfFirstResponder(longitudeTextField)
    }
    
    // MARK: TextField Validation
    
    private func isTextFieldValid(textField: UITextField, forRange: (Double, Double)) -> Bool {
        if let value = Double(textField.text!) where !textField.text!.isEmpty {
            return isValueInRange(value, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    private func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
    
}

// MARK: - ViewController (Configure UI)

extension ViewController {
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        phraseTextField.enabled = enabled
        latitudeTextField.enabled = enabled
        longitudeTextField.enabled = enabled
        phraseSearchButton.enabled = enabled
        latLonSearchButton.enabled = enabled
        
        // adjust search button alphas
        if enabled {
            phraseSearchButton.alpha = 1.0
            latLonSearchButton.alpha = 1.0
        } else {
            phraseSearchButton.alpha = 0.5
            latLonSearchButton.alpha = 0.5
        }
    }
    
}

// MARK: - ViewController (Notifications)

extension ViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}