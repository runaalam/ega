//
//  AddActivityViewController.swift
//  ega
//
//  Created by Runa Alam on 18/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class AddActivityViewController: XLFormViewController {
    
    var user: PFUser = PFUser()
    var userActivityLog: PFObject = PFObject(className: PF_USER_ACTIVITYLOG_CLASS_NAME)
    var activityList: [PFObject]! = []
    var activityDictionary = [String: Float]()
    
    fileprivate enum Tags : String {
        
        case Date = "date"
        case ActivitySelector = "activitySelector"
        case Duration = "duration"
        case Note = "note"
        case CaloriBurn = "caloriBurn"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    func initializeForm() {
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
    
        form = XLFormDescriptor(title: " Add Activity")

        section = XLFormSectionDescriptor.formSection(withTitle: "Activity Details")
        form.addFormSection(section)
        
        //Date
        row = XLFormRowDescriptor(tag: Tags.Date.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title:"Date")
        row.cellConfigAtConfigure["maximumDate"] = Date()
        row.isRequired = true
        section.addFormRow(row)
        
        // Activity Selector
        row = XLFormRowDescriptor(tag: Tags.ActivitySelector.rawValue, rowType:XLFormRowDescriptorTypeSelectorPush, title:"Select Activity")
        row.isRequired = true
        section.addFormRow(row)
        
        // Duration
        row = XLFormRowDescriptor(tag: Tags.Duration.rawValue, rowType:XLFormRowDescriptorTypeCountDownTimerInline, title:"Activity Duration")
        row.isRequired = true
        section.addFormRow(row)
        
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: Tags.Note.rawValue, rowType: XLFormRowDescriptorTypeTextView, title: "Notes")
        section.addFormRow(row)
       
        self.form = form
        
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == "duration" {
                NSLog("********** duration *************** \(formRow.value)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AddActivityViewController.cancelPressed(_:)))
        
        if user == PFUser.current() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(AddActivityViewController.savePressed(_:)))
        }
        
        if user != PFUser.current() {
            form.isDisabled = true
        }
        
        NSLog("*************INSIDE SELECTED Class************* \(userActivityLog)")
        if userActivityLog.objectId != nil {
            loadSelectedActivity()
        }
        checkUserInfo()
        loadActivity()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadActivity() {
        
        var query = PFQuery(className: PF_ACTIVITY_CLASS_NAME)
        query?.order(byAscending: PF_ACTIVITY_NAME)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.activityList.removeAll()
                self.activityList.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
                
                if self.activityList.count > 0 {
                    for activity in self.activityList {
                        var key = activity[PF_ACTIVITY_NAME] as! String
                        self.activityDictionary[key] = activity[PF_ACTIVITY_MET_VALUE] as? Float
                    }
                    
                    /*---- Add row with selector options -----*/
                    var activityRow : XLFormRowDescriptor = self.form.formRow(withTag: Tags.ActivitySelector.rawValue)
                    activityRow.selectorOptions = self.activityDictionary.keys.array
                }
                
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }

    }
    
    func loadSelectedActivity() {
        
        if userActivityLog[PF_USER_ACTIVITYLOG_DATE] != nil {
            form.formRow(withTag: "date").value = userActivityLog[PF_USER_ACTIVITYLOG_DATE]
        }
        
        if userActivityLog[PF_USER_ACTIVITYLOG_NAME] != nil {
            form.formRow(withTag: "activitySelector").value = userActivityLog[PF_USER_ACTIVITYLOG_NAME]
        }
        
        if userActivityLog[PF_USER_ACTIVITYLOG_DURATION] != nil {
            
            form.formRow(withTag: "duration").value = Utilities.convertDurationToCalender(userActivityLog[PF_USER_ACTIVITYLOG_DURATION] as! Int)
//            form.formRowWithTag("duration").value = userActivityLog[PF_USER_ACTIVITYLOG_DURATION]
       }
        
        if userActivityLog[PF_USER_ACTIVITYLOG_NOTE] != nil {
            form.formRow(withTag: "note").value = userActivityLog[PF_USER_ACTIVITYLOG_NOTE]
        }
    
    }
    
    func cancelPressed(_ button: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePressed(_ button: UIBarButtonItem) {
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        } else {
            saveUserActivity()
        }
        
        self.tableView.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        //NSLog("******* Data *******  ****** \(userActivityLog)")
    }
    
    func saveUserActivity() {
        
        var metValue = Float()
        var duration = Int()
        
        userActivityLog[PF_USER_ACTIVITYLOG_USER] = PFUser.current()
        
        if form.formRow(withTag: "date").value != nil {
            userActivityLog[PF_USER_ACTIVITYLOG_DATE] = form.formRow(withTag: "date").value
        }
        
        if form.formRow(withTag: "activitySelector").value != nil {
            userActivityLog[PF_USER_ACTIVITYLOG_NAME] = form.formRow(withTag: "activitySelector").value
            metValue = self.activityDictionary[form.formRow(withTag: "activitySelector").value as! String]!
        }
        
        if form.formRow(withTag: "duration").value != nil {
            duration = Utilities.durationCalculation(form.formRow(withTag: "duration").value as! Date)
            userActivityLog[PF_USER_ACTIVITYLOG_DURATION] = duration
        }
        
        if form.formRow(withTag: "note").value != nil {
            userActivityLog[PF_USER_ACTIVITYLOG_NOTE] = form.formRow(withTag: "note").value
        }
        
        userActivityLog[PF_USER_ACTIVITYLOG_CALORIE_BURN] = calculateCaloriBurn(metValue, duration: duration)
        
        userActivityLog.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                ProgressHUD.showSuccess("Saved")
                NSLog("------ Save data ------ . \(self.userActivityLog)")
            } else {
                NSLog("------ Error ------ . \(error)")
                ProgressHUD.showError("Network error")
            }
        })
        
        
        NSLog("---- User Activity ---- \(userActivityLog)")
    }
    
    func checkUserInfo() {
        
        let user = PFUser.current()
        
        if user?[PF_USER_HEIGHT] == nil || user?[PF_USER_WEIGHT] == nil || user?[PF_USER_GENDER] == nil || user?[PF_USER_DOB] == nil {
        
            
            let message = NSLocalizedString("Please fill up your weight, height and sex before recording activity", comment: "")
            let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
            let otherButtonTitle = NSLocalizedString("OK", comment: "")
        
            let alertCotroller = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
            // Create the actions.
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                self.dismiss(animated: true, completion: nil)
            }
        
            let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { action in
            
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileView") as! UINavigationController
                
                self.present(resultViewController, animated:true, completion:nil)
            }
        
            // Add the actions.
            alertCotroller.addAction(cancelAction)
            alertCotroller.addAction(otherAction)
        
            present(alertCotroller, animated: true, completion: nil)
        }
    }
    
    func calculateCaloriBurn(_ metValue: Float, duration: Int) -> Float {
    
        var user = PFUser.current()
        var BMR = Float()
        var caloriBurn = Float()
        var userAge = Utilities.calculateAge(user[PF_USER_DOB] as! Date)
        
        if (user?[PF_USER_GENDER] as AnyObject).isEqual("Male") {
            var weight = user?[PF_USER_WEIGHT] as! Float
            var height = user?[PF_USER_HEIGHT] as! Float
//            BMR = (13.75 * weight) + (5 * height) - (6.76 * userAge) + 66
            BMR = 0.0
            BMR += (13.75 * weight)
            BMR += (5 * height)
            BMR -= (6.76 * userAge.floatValue)
            BMR += 66
        } else {
            var weight = user?[PF_USER_WEIGHT] as! Float
            var height = user?[PF_USER_HEIGHT] as! Float
//            BMR = (9.56 * weight) + ( 18.5 * height) - (4.68 * userAge) + 655
            BMR = 0.0
            BMR += (9.56 * weight)
            BMR += (18.5 * height)
            BMR -= (4.68 * userAge.floatValue)
            BMR += 655

        }
        
        caloriBurn = ((BMR / 24.00) * metValue  * (Float(duration)/60))
        
        return caloriBurn
    }
}
