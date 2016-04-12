//
//  ViewController.swift
//  MemeMe
//
//  Created by Ivan Magda on 11.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//----------------------------------------------------
// MARK: - MemeEditorViewController: UIViewController
//----------------------------------------------------

class MemeEditorViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController = UIImagePickerController()
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    //------------------------------------------------
    // MARK: Actions
    //------------------------------------------------
    
    @IBAction func pickAnImageFromCameraDidPressed(sender: UIBarButtonItem) {
        shootPhoto()
    }
    
    @IBAction func pickAnImageFromAlbumDidPressed(sender: UIBarButtonItem) {
        photoFromLibrary()
    }
    
}

//-------------------------------------------------------------------
// MARK: - MemeEditorViewController (UI Functions)
//-------------------------------------------------------------------

extension MemeEditorViewController {
    
    private func configureUI() {
        imagePickerController.delegate = self
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    private func presentAlertWithTitle(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style:.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//-------------------------------------------------------------------
// MARK: - MemeEditorViewController: UIImagePickerControllerDelegate
//-------------------------------------------------------------------

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    
    //---------------------------------------
    // MARK: UIImagePickerControllerDelegate
    //---------------------------------------
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: Helper Methods
    //--------------------------------------
    
    /// Get a photo from the library.
    private func photoFromLibrary() {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.modalPresentationStyle = .FullScreen
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /// Take a picture, check if we have a camera first.
    private func shootPhoto() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .Camera
            imagePickerController.cameraCaptureMode = .Photo
            imagePickerController.modalPresentationStyle = .FullScreen
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            presentAlertWithTitle("No Camera", message: "Sorry, this device has no camera")
        }
    }
    
}

//------------------------------------------------------------------
// MARK: - MemeEditorViewController: UINavigationControllerDelegate
//------------------------------------------------------------------

extension MemeEditorViewController: UINavigationControllerDelegate {
}
