/**
 * Copyright (c) 2017 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// MARK: Types

private enum TextFieldTag: Int {
  case top = 100
  case bottom = 101
}

// MARK: - MemeViewController: UIViewController

class MemeViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var memeEditorContainerView: UIView!
  
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  
  // MARK: Properties
  
  var presentationType = MemeViewControllerPresentationType.showMeme
  
  var meme: Meme?
  var delegate: MemeViewControllerDelegate?
  
  private var shareMemeButton: UIBarButtonItem!
  
  /// Image picker controller to let us take/pick photo.
  private var imagePickerController = UIImagePickerController()
  
  /// Default text attributes for the meme text fields.
  private lazy var memeTextAttributes: [String: Any] = {
    return [
      NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
      NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
      NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
      NSAttributedStringKey.strokeWidth.rawValue : -2.5
    ]
  }()
  
  private var isBottomTextField = false
  private var keyboardOnScreen = false
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if presentationType == MemeViewControllerPresentationType.showMeme {
      assert(meme != nil)
    }
    
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromAllNotifications()
  }
  
  // MARK: Actions
  
  @IBAction func pickAnImageFromCameraDidPressed(_ sender: UIBarButtonItem) {
    shootPhoto()
  }
  
  @IBAction func pickAnImageFromAlbumDidPressed(_ sender: UIBarButtonItem) {
    photoFromLibrary()
  }
  
  @objc func actionBarButtonItemDidPressed() {
    if presentationType == MemeViewControllerPresentationType.showMeme {
      let alertController = UIAlertController(title: NSLocalizedString("Choose an action", comment: "Choose action alert controller title"), message: nil, preferredStyle: .actionSheet)
      
      /**
       * Share meme
       */
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Share", comment: "Share meme action name"), style: .default, handler: { action in
        guard self.delegate != nil else {
          return
        }
        
        self.share()
      }))
      
      /**
       * Update meme
       */
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: "Update action name"), style: .default, handler: { action in
        guard self.delegate != nil else {
          return
        }
        
        let newMeme = self.generateMeme()
        self.meme?.topText = newMeme.topText
        self.meme?.bottomText = newMeme.bottomText
        self.meme?.originalImage = newMeme.originalImage
        self.meme?.memedImage = newMeme.memedImage
        
        self.delegate!.memeViewController(self, didDoneOnMemeEditing: self.meme!)
        
        self.presentAlert(title: NSLocalizedString("Saved", comment: "Saved alert title"), message: NSLocalizedString("Your meme has been successfully saved", comment: "Saved alert meme message"))
      }))
      
      /**
       * Remove meme
       */
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove action name"), style: .destructive, handler: { action in
        guard self.delegate != nil else {
          return
        }
        
        self.delegate?.memeViewController(self, didSelectRemoveMeme: self.meme!)
        
        let alert = UIAlertController(
          title: NSLocalizedString("Removed", comment: "Removed meme alert title"),
          message: NSLocalizedString("Your meme successfully removed", comment: "Removed meme message"),
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
          self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
      }))
      
      /**
       * Cancel
       */
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action name"), style: .cancel, handler: nil))
      
      present(alertController, animated: true, completion: nil)
    } else {
      share()
    }
  }
  
  @objc fileprivate func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: Helpers
  
  fileprivate func generateMeme() -> Meme {
    return Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memeEditorContainerView.generateImage())
  }
  
  fileprivate func share() {
    let memeToShare = generateMeme()
    
    let activityViewController = UIActivityViewController(activityItems: [memeToShare.memedImage], applicationActivities: nil)
    
    let completionHandler: UIActivityViewControllerCompletionWithItemsHandler = { (activityType, completed, items, error) in
      guard error == nil else {
        self.presentAlert(message: error!.localizedDescription)
        return
      }
      
      if completed && self.delegate != nil {
        self.meme = memeToShare
        self.delegate?.memeViewController(self, didDoneOnMemeShare: self.meme!)
        
        let alert = UIAlertController(
          title: NSLocalizedString("Success", comment: "Success alert title"),
          message: NSLocalizedString("Your meme action successfully performed", comment: "Meme action alert message"),
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
          if self.presentationType == MemeViewControllerPresentationType.showMeme {
            self.navigationController?.popViewController(animated: true)
          } else {
            self.dismiss(animated: true, completion: nil)
          }
        }))
        self.present(alert, animated: true, completion: nil)
      }
    }
    activityViewController.completionWithItemsHandler = completionHandler
    
    
    present(activityViewController, animated: true, completion: nil)
  }
  
}

// MARK: - MemeViewController (UI Functions)

extension MemeViewController {
  
  fileprivate func configureUI() {
    shareMemeButton = UIBarButtonItem(barButtonSystemItem: .action,
                                      target: self,
                                      action: #selector(actionBarButtonItemDidPressed))
    switch presentationType {
    case .createMeme:
      let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel bar button item title"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(dismiss as () -> Void))
      navigationItem.leftBarButtonItem = shareMemeButton
      navigationItem.rightBarButtonItem = cancelButton
    case .showMeme:
      navigationItem.rightBarButtonItem = shareMemeButton
      
      topTextField.text = meme!.topText
      bottomTextField.text = meme!.bottomText
      imageView.image = meme!.originalImage
    }
    
    imagePickerController.delegate = self
    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    
    configureTextField(topTextField, tagType: .top)
    configureTextField(bottomTextField, tagType: .bottom)
    
    updateShareButtonEnabledState()
  }
  
  fileprivate func configureTextField(_ textField: UITextField, tagType tag: TextFieldTag) {
    textField.delegate = self
    textField.tag = tag.rawValue
    textField.defaultTextAttributes = memeTextAttributes
    textField.textAlignment = .center
    
    if presentationType == MemeViewControllerPresentationType.createMeme {
      switch tag {
      case .top:
        textField.text = NSLocalizedString("TOP", comment: "Top text field initial text")
      case .bottom:
        textField.text = NSLocalizedString("BOTTOM", comment: "Bottom text field initial text")
      }
    }
  }
  
  fileprivate func updateShareButtonEnabledState() {
    shareMemeButton.isEnabled = imageView.image != nil
  }
  
  fileprivate func presentAlert(title: String = NSLocalizedString("Error", comment: "Error alert title"), message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style:.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
}

// MARK: - MemeViewController: UIImagePickerControllerDelegate

extension MemeViewController: UIImagePickerControllerDelegate {
  
  // MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = pickedImage
      updateShareButtonEnabledState()
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }

  // MARK: Helper Methods
  
  /// Get a photo from the library.
  fileprivate func photoFromLibrary() {
    imagePickerController.allowsEditing = false
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.modalPresentationStyle = .fullScreen
    
    present(imagePickerController, animated: true, completion: nil)
  }
  
  /// Take a picture, check if we have a camera first.
  fileprivate func shootPhoto() {
    if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
      imagePickerController.allowsEditing = false
      imagePickerController.sourceType = .camera
      imagePickerController.cameraCaptureMode = .photo
      imagePickerController.modalPresentationStyle = .fullScreen
      
      present(imagePickerController, animated: true, completion: nil)
    } else {
      presentAlert(title: "No Camera", message: "Sorry, this device has no camera")
    }
  }
  
}

// MARK: - MemeViewController: UINavigationControllerDelegate

extension MemeViewController: UINavigationControllerDelegate {
}

// MARK: - MemeViewController: UITextFieldDelegate

extension MemeViewController: UITextFieldDelegate {
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    isBottomTextField = textField.tag == TextFieldTag.bottom.rawValue
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return textField.text?.count > 0
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    isBottomTextField = false
  }
  
  // MARK: Show/Hide Keyboard
  
  @objc func keyboardWillShow(_ notification: Notification) {
    if !keyboardOnScreen && isBottomTextField {
      view.frame.origin.y = keyboardHeight(notification) * -1
    }
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    if keyboardOnScreen && isBottomTextField  {
      view.frame.origin.y = 0
    }
  }
  
  @objc func keyboardDidShow(_ notification: Notification) {
    keyboardOnScreen = true
  }
  
  @objc func keyboardDidHide(_ notification: Notification) {
    keyboardOnScreen = false
  }
  
  fileprivate func keyboardHeight(_ notification: Notification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    return keyboardSize.cgRectValue.height
  }
  
  fileprivate func resignIfFirstResponder(_ textField: UITextField) {
    if textField.isFirstResponder {
      textField.resignFirstResponder()
    }
  }
  
  @IBAction func userDidTapView(_ sender: AnyObject) {
    resignIfFirstResponder(topTextField)
    resignIfFirstResponder(bottomTextField)
  }
  
}

// MARK: - MemeViewController (Notifications)

extension MemeViewController {
  
  fileprivate func subscribeToKeyboardNotifications() {
    subscribeToNotification(NSNotification.Name.UIKeyboardWillShow.rawValue, selector: #selector(MemeViewController.keyboardWillShow(_:)))
    subscribeToNotification(NSNotification.Name.UIKeyboardWillHide.rawValue, selector: #selector(MemeViewController.keyboardWillHide(_:)))
    subscribeToNotification(NSNotification.Name.UIKeyboardDidShow.rawValue, selector: #selector(MemeViewController.keyboardDidShow(_:)))
    subscribeToNotification(NSNotification.Name.UIKeyboardDidHide.rawValue, selector: #selector(MemeViewController.keyboardDidHide(_:)))
  }
  
  fileprivate func subscribeToNotification(_ notification: String, selector: Selector) {
    NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: notification), object: nil)
  }
  
  fileprivate func unsubscribeFromAllNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
}
