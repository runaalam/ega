//
//  PostDetailViewController.swift
//  ega
//
//  Created by Runa Alam on 2/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,
    UIPopoverPresentationControllerDelegate {
    
    var userPost: PFObject = PFObject(className: PF_POST_CLASS_NAME)
   
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    // @IBOutlet weak var writePostNavigation: UINavigationItem!
    // @IBOutlet weak var diaryViewToolbar: UIToolbar!
    
    let PLACEHOLDER_TEXT = "Write somthing here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let date = Date()
    
       // configureToolbar()
       // configureNavigationBar()
    
        applyPlaceholderStyle(textView!, placeholderText: PLACEHOLDER_TEXT)
    
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        textView?.delegate = self
        
        updateDatePickerLabel(date)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PostDetailViewController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PostDetailViewController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        textView.resignFirstResponder()
        navigationItem.setLeftBarButton(nil, animated: true)
        self.dismiss(animated: true, completion: nil)
        //showCancelActionSheet()
    }
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        
        // Dismiss the keyboard by removing it as the first responder.
        textView.resignFirstResponder()
        navigationItem.setRightBarButton(nil, animated: true)
        self.savePost()
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func privacyButtonClicked(_ sender: AnyObject) {
        
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Only Me", "Network", "Public", "Group")
        actionSheet.show(from: (self.tabBarController?.tabBar)!)
        
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        if textView.text == PLACEHOLDER_TEXT {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func trashButtonPressed(_ sender: AnyObject) {
        
        self.showDeleteCancelActionSheet()
    }
    
    
    @IBAction func commentButtonPressed(_ sender: AnyObject) {
        
        
        if userPost.objectId != nil {
            
            let popoverVC = storyboard?.instantiateViewController(withIdentifier: "CommentPop") as! CommentViewController
            popoverVC.userPost = Post(post: self.userPost, user: PFUser.current())
            //popoverVC.user = PFUser.currentUser()
            popoverVC.modalPresentationStyle = .popover
            
            if let popoverController = popoverVC.popoverPresentationController {
                // popoverController.sourceView = sender as! UIView
                //popoverController.sourceRect = sender.bounds
                popoverController.permittedArrowDirections = .any
                popoverController.delegate = self
            }
            present(popoverVC, animated: true, completion: nil)
        } else {
            showCommentButtonAction()
            //ProgressHUD.show("Can not comment without saving new post")
        }

        
    }
    
    func loadPost() {
        
        if userPost.objectId != nil {
    
            if userPost[PF_POST_DATE] != nil {
            
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.long
                formatter.timeStyle = .short
            
                let dateString = formatter.string(for: userPost[PF_POST_DATE])!
                dateLabel.text = "\(dateString)"
            }
        
            if userPost[PF_POST_TITLE] != nil {
                titleText.text = "\(userPost[PF_POST_TITLE])"
            }
        
            if userPost[PF_POST_DESCRITION] != nil {
                textView.text = "\(userPost[PF_POST_DESCRITION])"
                textView.textColor = UIColor.black
                
            }
        
            if userPost[PF_POST_PRIVACY] != nil {
                
                privacyLabel.text = Utilities.getPrivacyString(userPost[PF_POST_PRIVACY] as! Int)
            }
        }
    }
    
    // MARK: Configuration
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
    
        self.dismiss(animated: true, completion: nil)
    
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText!)
        let textAttachment = NSTextAttachment()
    
        textAttachment.image = Toucan(image: image).resize(CGSize(width: 330, height: 250), fitMode: Toucan.Resize.FitMode.scale).image
        let textAttachmentString = NSAttributedString(attachment: textAttachment)
    
        attributedText.append(textAttachmentString)
        textView.attributedText = attributedText
    
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
    
    // MARK: UIBarButton Actions
    

    func savePost() {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .short
        let date = formatter.date(from: dateLabel.text!)
        var privacynumber = Utilities.getPrivacyInt(privacyLabel.text!)
        let title = titleText.text
        let description = textView.text
        
        if count(description) > 0 && privacynumber > 0{
            
            userPost[PF_POST_USER] = PFUser.current()
            userPost[PF_POST_TITLE] = title
            userPost[PF_POST_DATE] = date
            userPost[PF_POST_DESCRITION] = description
            userPost[PF_POST_PRIVACY] = privacynumber
           
            userPost.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                    ProgressHUD.showSuccess("Saved")
                    NSLog("------ Save data ------ . \(self.userPost)")
                } else {
                    NSLog("------ Error ------ . \(error)")
                    
                    ProgressHUD.showError("Network error")
                }
            })
        
        } else {
            if (description?.isEmpty)! {
                ProgressHUD.showError("Must write something in post")
                
            }
            
            if privacynumber == 0 {
                ProgressHUD.showError("Must set privacy for this post")
                
            }
        }
        
    }
    
    func updateDatePickerLabel(_ date: Date) {
    
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .short
    
        let dateString = formatter.string(from: date)
        self.dateLabel.text = "\(dateString)"
    
    }
    
    func applyPlaceholderStyle(_ aTextview: UITextView, placeholderText: String){
        textView.text = PLACEHOLDER_TEXT
        textView.textColor = UIColor.lightGray
    
        textView.becomeFirstResponder()
    
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    // make it look like normal text instead of a placeholder
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
        let currentText:NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
    
        // If updated text view will be empty, add the placeholder and set the cursor to the beginning of the text view
        if count(updatedText) == 0 {
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            return false
        } else if textView.text == PLACEHOLDER_TEXT {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.text == PLACEHOLDER_TEXT {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                
                }
        }
    }
    
    /* --------------------- MARK: Keyboard Event Notifications -------------------------- */
    
    func handleKeyboardWillShowNotification(_ notification: Notification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
    }
    
    func handleKeyboardWillHideNotification(_ notification: Notification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
    }
    
    func keyboardWillChangeFrameWithNotification(_ notification: Notification, showsKeyboard: Bool) {
        let userInfo = notification.userInfo!
    
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as!NSNumber).doubleValue
    
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    
        let keyboardViewBeginFrame = view.convert(keyboardScreenBeginFrame, from: view.window)
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
    
        // The text view should be adjusted, update the constant for this constraint.
        textViewBottomLayoutGuideConstraint.constant -= originDelta
    
        view.setNeedsUpdateConstraints()
    
        UIView.animate(withDuration: animationDuration, delay: 0, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    
        // Scroll to the selected text once the keyboard frame changes.
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    /*------------------------------ Create Action sheets ----------------------------------*/
    
    func showDeleteCancelActionSheet() {
    
        let destructiveButtonTitle = NSLocalizedString("Delete", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "OK")
    
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        // Create the actions.
        let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .destructive) { action in
            NSLog("The \"Okay/Cancel\" alert action sheet's destructive action occured.")
            self.userPost.deleteInBackground({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                    ProgressHUD.showSuccess("Deleted")
                } else {
                    NSLog("------ Error ------ . \(error)")
                    
                    ProgressHUD.showError("Network error")
                }
            })
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Okay/Cancel\" alert action sheet's cancel action occured.")
        }
    
        // Add the actions.
    
        alertController.addAction(destructiveAction)
        alertController.addAction(cancelAction)
    
        present(alertController, animated: true, completion: nil)
    }
    
    func showCancelActionSheet() {
    
        //  let title = NSLocalizedString("A Short Title is Best", comment: "")
        let message = NSLocalizedString("Are you sure you want to cancel what you have done?", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let otherButtonTitle = NSLocalizedString("OK", comment: "")
    
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
    
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            self.dismiss(animated: true, completion: nil)
        }
    
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
    
        present(alertCotroller, animated: true, completion: nil)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch buttonIndex {
            case 1:
                    privacyLabel.text = "Only Me"
            case 2:
                    privacyLabel.text = "Network"
            case 3:
                    privacyLabel.text = "Public"
            case 4:
                    privacyLabel.text = "Group"
            default:
                return
            }
        }
    }
    
    func showCommentButtonAction() {
        
        //  let title = NSLocalizedString("A Short Title is Best", comment: "")
        let message = NSLocalizedString("Can not comment without saving new post", comment: "")
        let otherButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
        }
        
        // Add the actions.
        alertCotroller.addAction(otherAction)
        
        present(alertCotroller, animated: true, completion: nil)
    }
}
