//
//  ViewController.swift
//  MemeMe
//
//  Created by Ivan Magda on 11.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//----------------------------------------------------
// MARK: Types
//----------------------------------------------------

private enum TextFieldTag: Int {
    case Top = 100
    case Bottom = 101
}

//----------------------------------------------------
// MARK: - MemeViewController: UIViewController
//----------------------------------------------------

class MemeViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var memeEditorContainerView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    var presentationType = MemeViewControllerPresentationType.ShowMeme
    
    var meme: Meme?
    
    private var shareMemeButton: UIBarButtonItem!
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController = UIImagePickerController()
    
    /// Default text attributes for the meme text fields.
    private lazy var memeTextAttributes: [String: AnyObject] = {
        return [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.5
        ]
    }()
    
    private var isBottomTextFieldActive = false
    private var keyboardOnScreen = false
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presentationType == MemeViewControllerPresentationType.ShowMeme {
            assert(meme != nil)
        }
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
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
    
    func shareMeme() {
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memeEditorContainerView.generateImage())
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

//-------------------------------------------------------------------
// MARK: - MemeViewController (UI Functions)
//-------------------------------------------------------------------

extension MemeViewController {
    
    private func configureUI() {
        shareMemeButton = UIBarButtonItem(barButtonSystemItem: .Action,
                                          target: self,
                                          action: #selector(MemeViewController.shareMeme))
        switch presentationType {
        case .CreateMeme:
            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel",
                comment: "Cancel bar button item title"),
                                               style: .Plain,
                                               target: self,
                                               action: #selector(MemeViewController.dismiss))
            navigationItem.leftBarButtonItem = shareMemeButton
            navigationItem.rightBarButtonItem = cancelButton
        case .ShowMeme:
            navigationItem.rightBarButtonItem = shareMemeButton
        }
        
        imagePickerController.delegate = self
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        configureTextField(topTextField, tagType: .Top)
        configureTextField(bottomTextField, tagType: .Bottom)
        
        updateShareButtonEnabledState()
    }
    
    private func configureTextField(textField: UITextField, tagType tag: TextFieldTag) {
        textField.delegate = self
        textField.tag = tag.rawValue
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        
        switch tag {
        case .Top:
            textField.text = NSLocalizedString("TOP", comment: "Top text field initial text")
        case .Bottom:
            textField.text = NSLocalizedString("BOTTOM", comment: "Bottom text field initial text")
        }
    }
    
    private func updateShareButtonEnabledState() {
        shareMemeButton.enabled = imageView.image != nil
    }
    
    private func presentAlertWithTitle(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style:.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//-------------------------------------------------------------------
// MARK: - MemeViewController: UIImagePickerControllerDelegate
//-------------------------------------------------------------------

extension MemeViewController: UIImagePickerControllerDelegate {
    
    //---------------------------------------
    // MARK: UIImagePickerControllerDelegate
    //---------------------------------------
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            updateShareButtonEnabledState()
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
// MARK: - MemeViewController: UINavigationControllerDelegate
//------------------------------------------------------------------

extension MemeViewController: UINavigationControllerDelegate {
}

//-------------------------------------------------------
// MARK: - MemeViewController: UITextFieldDelegate
//-------------------------------------------------------

extension MemeViewController: UITextFieldDelegate {
    
    //----------------------------------------------
    // MARK: UITextFieldDelegate
    //----------------------------------------------
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        isBottomTextFieldActive = textField.tag == TextFieldTag.Bottom.rawValue
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return textField.text?.characters.count > 0
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        isBottomTextFieldActive = false
    }
    
    //----------------------------------------------
    // MARK: Show/Hide Keyboard
    //----------------------------------------------
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen && isBottomTextFieldActive {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen && isBottomTextFieldActive  {
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
        resignIfFirstResponder(topTextField)
        resignIfFirstResponder(bottomTextField)
    }
    
}

//--------------------------------------------------
// MARK: - MemeViewController (Notifications)
//--------------------------------------------------

extension MemeViewController {
    
    private func subscribeToKeyboardNotifications() {
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(MemeViewController.keyboardWillShow(_:)))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(MemeViewController.keyboardWillHide(_:)))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(MemeViewController.keyboardDidShow(_:)))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(MemeViewController.keyboardDidHide(_:)))
    }
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
