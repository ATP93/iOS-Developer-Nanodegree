//
//  FlickrApiClient.swift
//  VirtualTourist
//
//  Created by Ivan Magda on 17/05/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

//---------------------------------------------------------
// MARK: Typealiases
//---------------------------------------------------------

typealias MethodParameters = [String: AnyObject]

typealias FlickPhotoTaskCompletionHandler = (photos: [JSONDictionary]?, error: NSError?) -> Void
typealias FlickrImageDownloadingCompletionHandler = (imageData: NSData?, error: NSError?) -> Void

//---------------------------------------------------------
// MARK: - FlickrApiClient: JsonApiClient
//---------------------------------------------------------

class FlickrApiClient: JsonApiClient {
    
    //-------------------------------------------------
    // MARK: - Properties -
    //-------------------------------------------------
    
    // MARK: Shared Instance
    
    /**
     *  This class variable provides an easy way to get access
     *  to a shared instance of the FlickrApiClient class.
     */
    class var sharedInstance: FlickrApiClient {
        struct Static {
            static var instance: FlickrApiClient?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.timeoutIntervalForRequest  = 30.0
            config.timeoutIntervalForResource = 60.0
            
            let client = FlickrApiClient(configuration: config)
            client.loggingEnabled = true
            
            Static.instance = client
        }
        
        return Static.instance!
    }
    
    //-------------------------------------------------
    // MARK: - Calling Api Endpoints
    //-------------------------------------------------
    
    // MARK: Public
    
    func fetchPhotosByCoordinate(coordinate: CLLocationCoordinate2D, pageNumber page: Int = 1, itemsPerPage perPage: Int = 100, completionHandler: FlickPhotoTaskCompletionHandler) {
        // GUARD: Are the range is valid?
        guard isCoordinateValid(coordinate.latitude, forRange: Constants.Flickr.SearchLatRange) &&
            isCoordinateValid(coordinate.longitude, forRange: Constants.Flickr.SearchLonRange) else {
                let errorMessage = "Latitude should be [-90, 90].\nLongitude should be [-180, 180]."
                debugLog("Error: \(errorMessage)")
                let error = NSError(
                    domain: FlickrApiClient.FetchPhotosByCoordinateErrorDomain,
                    code: FlickrApiClient.FetchPhotosByCoordinateErrorCode,
                    userInfo: [NSLocalizedDescriptionKey : errorMessage]
                )
                completionHandler(photos: nil, error: error)
                return
        }
        
        var methodParameters = getBaseMethodParameters()
        methodParameters[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.SearchMethod
        methodParameters[Constants.FlickrParameterKeys.Extras] = "\(Constants.FlickrParameterValues.ThumbnailURL),\(Constants.FlickrParameterValues.MediumURL)"
        methodParameters[Constants.FlickrParameterKeys.Page] = page
        methodParameters[Constants.FlickrParameterKeys.PerPage] = perPage
        methodParameters[Constants.FlickrParameterKeys.BoundingBox] = bboxString(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        fetchPhotosWithMethodParameters(methodParameters, completionHandler: completionHandler)
    }
    
    func loadImageData(url: NSURL, completionHandler: FlickrImageDownloadingCompletionHandler) {
        fetchRawData(NSURLRequest(URL: url)) { apiClientResult in
            performOnMain {
                func sendError(error: String) {
                    self.debugLog("Error: \(error)")
                    let error = NSError(
                        domain: FlickrApiClient.LoadImageErrorDomain,
                        code: FlickrApiClient.LoadImageErrorCode,
                        userInfo: [NSLocalizedDescriptionKey : error]
                    )
                    completionHandler(imageData: nil, error: error)
                }
                
                switch apiClientResult {
                case .Error(let error):
                    sendError(error.localizedDescription)
                case .RawData(let data):
                    completionHandler(imageData: data, error: nil)
                default:
                    sendError(apiClientResult.defaultErrorMessage()!)
                }
            }
        }
    }
    
    /// Returns number of pages for a photo search.
    func numberOfPagesForFlickrPhotoSearch(completionHandler: (Int, NSError?) -> Void) {
        var methodParameters = getBaseMethodParameters()
        methodParameters[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.SearchMethod
        let request = NSURLRequest(URL: urlFromParameters(methodParameters))
        
        fetchJson(request) { apiClientResult in
            performOnMain {
                func sendError(error: String) {
                    self.debugLog("Error: \(error)")
                    let error = NSError(
                        domain: FlickrApiClient.NumberOfPagesForPhotoSearchErrorDomain,
                        code: FlickrApiClient.NumberOfPagesForPhotoSearchErrorCode,
                        userInfo: [NSLocalizedDescriptionKey : error]
                    )
                    completionHandler(0, error)
                }
                
                switch apiClientResult {
                case .Error(let error):
                    sendError(error.localizedDescription)
                case .Json(let json):
                    guard let photosDictionary = json[Constants.FlickrResponseKeys.Photos] as? JSONDictionary,
                        let numberOfPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                            sendError("Could't parse recieved JSON object")
                            return
                    }
                    
                    completionHandler(numberOfPages, nil)
                default:
                    sendError(apiClientResult.defaultErrorMessage()!)
                }
            }
        }
    }
    
    // MARK: Private
    
    private func fetchPhotosWithMethodParameters(param: MethodParameters, completionHandler: FlickPhotoTaskCompletionHandler) {
        func sendError(error: String) {
            debugLog("Error: \(error)")
            let error = NSError(
                domain: FlickrApiClient.FetchPhotosErrorDomain,
                code: FlickrApiClient.FetchPhotosErrorCode,
                userInfo: [NSLocalizedDescriptionKey : error]
            )
            completionHandler(photos: nil, error: error)
        }
        
        let request = NSURLRequest(URL: urlFromParameters(param))
        fetchJson(request) { apiClientResult in
            performOnMain {
                switch apiClientResult {
                case .Error(let error):
                    sendError(error.localizedDescription)
                case .Json(let json):
                    // GUARD: Did Flickr return an error?
                    guard let flickrStatus = json[Constants.FlickrResponseKeys.Status] as? String where flickrStatus == Constants.FlickrResponseValues.OKStatus else {
                        sendError("Flick API returned an error.")
                        return
                    }
                    
                    // GUARD: Are the "photos" and "photo" keys in our result.
                    guard let photosDictionary = json[Constants.FlickrResponseKeys.Photos] as? JSONDictionary,
                        let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [JSONDictionary] else {
                            sendError("Cannot find 'photos' or 'photo' keys!")
                            return
                    }
                    
                    guard photoArray.count > 0 else {
                        sendError("No photo found. Try again.")
                        return
                    }
                    
                    completionHandler(photos: photoArray, error: nil)
                default:
                    sendError(apiClientResult.defaultErrorMessage()!)
                }
            }
        }
    }
    
    //-------------------------------------------------
    // MARK: - Helpers
    //-------------------------------------------------
    
    private func getBaseMethodParameters() -> MethodParameters {
        return [
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    private func isCoordinateValid(coordinate: Double, forRange range: SearchCoordinateRange) -> Bool {
        return !(coordinate < range.start || coordinate > range.end)
    }
    
    private func bboxString(latitude latitude: Double, longitude: Double) -> String {
        let minLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.start)
        let minLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.start)
        
        let maxLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.end)
        let maxLan = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.end)
        
        return "\(minLon),\(minLat),\(maxLon),\(maxLan)"
    }
    
    /// Helper for Creating a URL from Parameters.
    private func urlFromParameters(parameters: MethodParameters) -> NSURL {
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
