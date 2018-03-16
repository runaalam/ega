//
//  MyProfileTableViewController.swift
//  ega
//
//  Created by Runa Alam on 27/05/2015.
//  Copyright (c) 2015 Runa Alam. All rights reserved.
//

import UIKit

class MyProfileTableViewController: UITableViewController,UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GroupSelectViewControllerDelegate {
    
    var popDatePicker : PopDatePicker?

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var userImageView: PFImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var groupLabel: UILabel!
    
    var userGenderValue = ""
    var userGroup: PFObject = PFObject(className: PF_GROUP_CLASS_NAME)

    override func viewDidLoad() {
        super.viewDidLoad()
    
        popDatePicker = PopDatePicker(forTextField: dobTextField)
        dobTextField.delegate = self
        
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))

        configureGenderSegmentedControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = PFUser.current() {
            self.loadUser()
        } else {
            Utilities.loginUser(self)
        }
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
        imageButton.layer.cornerRadius = userImageView.frame.size.width / 2;
        imageButton.layer.masksToBounds = true;
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func loadUser() {
        
        resign()
        
        var user = PFUser.current()
        
        userImageView.file = user?[PF_USER_PICTURE] as? PFFile
        userImageView.load { (image: UIImage!, error: NSError!) -> Void in
            if error != nil {
                println(error)
            }
        }
        
        nameField.text = user?[PF_USER_FULLNAME] as! String
        
        if user?[PF_USER_EMAIL] != nil {
            emailLabel.text = user?[PF_USER_EMAIL] as? String
        }
        
        if user?[PF_USER_EMAILCOPY] != nil {
            emailLabel.text = user?[PF_USER_EMAILCOPY] as? String
        }
        
        if user?[PF_USER_GENDER] != nil {
            if (user?[PF_USER_GENDER] as AnyObject).isEqual("Male") {
                genderSegment.selectedSegmentIndex = 0
            } else if (user?[PF_USER_GENDER] as AnyObject).isEqual("Female") {
                genderSegment.selectedSegmentIndex = 1
            }
        }
        
        if user?[PF_USER_DOB] != nil {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            let dateString = formatter.string(for: user?[PF_USER_DOB])!
            dobTextField.text = "\(dateString)"
            
        } else {
           // dobTextField.text = ""
        }
        
        if user? [PF_USER_HEIGHT] != nil {
            heightTextField.text = "\(user? [PF_USER_HEIGHT])"
        }
        
        if user? [PF_USER_WEIGHT] != nil {
            weightTextField.text = "\(user? [PF_USER_WEIGHT])"
        }
        
        if  user? [PF_USER_GROUP] != nil {
            
            var selectedGroup = user?[PF_USER_GROUP] as! PFObject
          
            var query = PFQuery(className: PF_GROUP_CLASS_NAME)
            query?.whereKey(PF_GROUP_OBJECTID, equalTo: selectedGroup.objectId)
            query.findObjectsInBackground {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            self.groupLabel.text = "\(object[PF_GROUP_NAME])"
                        }
                    }

                } else {
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }

        }
    }
    
    func configureGenderSegmentedControl() {
        genderSegment.tintColor = UIColor.applicationBlueColor()
        
        genderSegment.selectedSegmentIndex = 0
        self.userGenderValue = "Male"
        
        genderSegment.addTarget(self, action: #selector(MyProfileTableViewController.selectedSegmentDidChange(_:)), for: .valueChanged)
    }
    
    // MARK: Actions
    
    func selectedSegmentDidChange(_ segmentedControl: UISegmentedControl) {
        NSLog("The selected segment changed for: \(segmentedControl).")
        
        var user = PFUser.current()
        
        if genderSegment.selectedSegmentIndex == 0{
            self.userGenderValue = "Male"
        } else {
            self.userGenderValue = "Female"
        }
    }
    
    func resign() {
        imageButton.resignFirstResponder()
        nameField.resignFirstResponder()
        genderSegment.resignFirstResponder()
        weightTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        dobTextField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField === dobTextField) {
            resign()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let initDate : Date? = formatter.date(from: dobTextField.text!)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        } else {
            return true
        }
    }
  
    func saveUser() {
        
        let fullName = nameField.text
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dob = formatter.date(from: dobTextField.text!)
        
        let height = heightTextField.text.toInt()
        let weight = weightTextField.text.toInt()
        let group = groupLabel.text
        
        if count(fullName) > 0 && dob != nil && height != nil  && weight != nil && group != nil{
            
            var user = PFUser.current()
            user?[PF_USER_FULLNAME] = fullName
            user?[PF_USER_FULLNAME_LOWER] = fullName?.lowercased()
            user?[PF_USER_DOB] = dob
            user?[PF_USER_GENDER] = self.userGenderValue
            user?[PF_USER_GROUP] = userGroup
            
            /*var relation = user.relationForKey("group")
            relation.addObject(userGroup)*/
            
            NSLog("------ usergroup ------ . \(userGroup)")
            
            if weight > 0 {
                user[PF_USER_WEIGHT] = weight
            } else {
                ProgressHUD.showError("Weight must be greater than 0")
            }
            if height > 0 {
                user[PF_USER_HEIGHT] = height
            } else {
                ProgressHUD.showError("Height must be greater than 0")
            }
            
            user.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                    ProgressHUD.showSuccess("Saved")
                } else {
                    NSLog("------ Error ------ . \(error)")

                    ProgressHUD.showError("Network error")
                }
            })
        } else {
            if (fullName?.isEmpty)! {
                ProgressHUD.showError("Name field must not be empty")
            }
            
            if dob == nil {
                ProgressHUD.showError("Date of Birth must not be empty")
            }
            
            if weight == nil {
                ProgressHUD.showError("Weight must not be empty")
            }
            
            if height == nil {
                ProgressHUD.showError("Height must not be empty")
            }
            
            if group == nil {
                 ProgressHUD.showError("Select your group")
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        if image.size.width > 280 {
            image = Images.resizeImage(image, width: 280, height: 280)!
        }
        
        var pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6))
        pictureFile.saveInBackground { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                ProgressHUD.showError("Network error")
            }
        }
        
        userImageView.image = image
        
        if image.size.width > 60 {
            image = Images.resizeImage(image, width: 60, height: 60)!
        }
        
        var thumbnailFile = PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(image, 0.6))
        thumbnailFile.saveInBackground { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                ProgressHUD.showError("Network error")
            }
        }
        
        var user = PFUser.current()
        user?[PF_USER_PICTURE] = pictureFile
        user?[PF_USER_THUMBNAIL] = thumbnailFile
        user.saveInBackground { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                ProgressHUD.showError("Network error")
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        Camera.shouldStartPhotoLibrary(self, canEdit: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        self.dismissKeyboard()
        self.saveUser()
    }
    
    func didSelectGroup(_ group: PFObject) {
        NSLog("------ Group object ------  \(group)")
       
        userGroup = group
        groupLabel.text = group[PF_GROUP_NAME] as? String
       
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 7
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         //NSLog("------ INSIDE DID SELECT MY PROFILE \(indexPath.row)-------- ")
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "selectGroup" {
            let groupSelectVC = segue.destinationViewController.topViewController as! GroupSelectViewController
                groupSelectVC.delegate = self
        }
    }
}
