//
//  TestXLFormViewController.swift
//  ega
//
//  Created by Runa Alam on 1/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class AddMedicationFormViewController: XLFormViewController {
    
    var user: PFUser = PFUser()
    var userMedication: PFObject = PFObject(className: PF_MEDICATION_CLASS_NAME)
    var timeListWithTag = [String: Date]()
    var index = 0
    
    fileprivate enum Tags : String {
        case RegulerMedication = "regulerMedicationEnable"
        case StartDate = "startDate"
        case EndDate = "endDate"
        case Date = "date"
        
        case MedicationName = "name"
        case Description = "description"
        case Dose = "dose"
        case Time = "time"
        case MedictionReminder = "reminderEnable"
        case ReminderAlert = "reminderAlert"
        case Note = "note"
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
        
        
        form = XLFormDescriptor(title: "Add Medication")
        form.assignFirstResponderOnShow = true
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
        
        //regulerMedicationEnable
        row = XLFormRowDescriptor(tag: Tags.RegulerMedication.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title:"Reguler Medication")
        row.value = true
        section.addFormRow(row)
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor()
        section.title = "Medication Details"
        form.addFormSection(section)
        
        //name
        row = XLFormRowDescriptor(tag: Tags.MedicationName.rawValue, rowType: XLFormRowDescriptorTypeText, title:"Name")
        row.isRequired = true
        section.addFormRow(row)
        
        // description
        row = XLFormRowDescriptor(tag: Tags.Description.rawValue, rowType: XLFormRowDescriptorTypeText, title: "Description")
        section.addFormRow(row)
        
        // description
        row = XLFormRowDescriptor(tag: Tags.Dose.rawValue, rowType: XLFormRowDescriptorTypeText, title: "Dose")
        section.addFormRow(row)
        
        //startDate
        row = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title:"Start Date")
        row.value = Date.new()
        section.addFormRow(row)
        row.hidden = NSPredicate(format: "$\(Tags.RegulerMedication.rawValue).value==0")
        
        //endDate
        row = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title:"End Date")
        row.value = Date.new()
        section.addFormRow(row)
        row.hidden = NSPredicate(format: "$\(Tags.RegulerMedication.rawValue).value==0")
        
        //date
        row = XLFormRowDescriptor(tag: Tags.Date.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title:"Date")
        row.value = Date.new()
        section.addFormRow(row)
        row.hidden = NSPredicate(format: "$\(Tags.RegulerMedication.rawValue).value==1")
        
        form.addFormSection(section)
        
        //time with delete
        section = XLFormSectionDescriptor.formSectionWithTitle("Medication Time", sectionOptions:XLFormSectionOptions.CanReorder | XLFormSectionOptions.CanInsert | XLFormSectionOptions.CanDelete, sectionInsertMode:XLFormSectionInsertMode.Button)
        
        section.multivaluedAddButton.title = "Add Time"
        // set up the row template
        row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeTimeInline, title: "Time")
        //row.title = "Time"
        section.multivaluedRowTemplate = row
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor()
        section.title = "Reminder"
        form.addFormSection(section)
        
        //reminderEnable
        row = XLFormRowDescriptor(tag: Tags.MedictionReminder.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title:"Enable")
        row.value = true
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        // Notes
        row = XLFormRowDescriptor(tag: Tags.Note.rawValue, rowType:XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure["textView.placeholder"] = "Notes"
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
        
        self.form = form
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AddMedicationFormViewController.cancelPressed(_:)))
        
        if user == PFUser.current() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(AddMedicationFormViewController.savePressed(_:)))
        }
        
        if user != PFUser.current() {
            form.isDisabled = true
        }

        loadUserMedication()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
      
        
        if formRow.title == "Time" {
            formRow.tag = "\(formRow.title)\(index++)"
            timeListWithTag[formRow.tag] = newValue as? Date!
          //  NSLog("-- Add --- \(formRow.tag)----")
        }
    }
    
    
    override func formRowHasBeenRemoved(_ formRow: XLFormRowDescriptor!, at indexPath: IndexPath!) {
        super.formRowHasBeenRemoved(formRow, at: indexPath)
    
        if formRow.tag != nil {
            timeListWithTag.removeValue(forKey: formRow.tag)
           // NSLog("-- Remove --- \(formRow.tag)---- ")
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
            saveUserMedication()
        }
        
        self.tableView.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        //NSLog("******* Data *******  ****** \(userMedication)")
    }
    
    func loadUserMedication() {
        if userMedication[PF_MEDICATION_NAME] != nil {
            form.formRow(withTag: "name").value = userMedication[PF_MEDICATION_NAME]
        }
        
        if userMedication[PF_MEDICATION_DESCRITION] != nil {
            form.formRow(withTag: "description").value = userMedication[PF_MEDICATION_DESCRITION]
        }
        
        if userMedication[PF_MEDICATION_DOSE] != nil {
            form.formRow(withTag: "dose").value = userMedication[PF_MEDICATION_DOSE]
        }
        
        if userMedication[PF_MEDICATION_NOTE] != nil {
            form.formRow(withTag: "note").value = userMedication[PF_MEDICATION_NOTE]
        }
        
        if userMedication[PF_MEDICATION_START_DATE] != nil {
            form.formRow(withTag: "startDate").value = userMedication[PF_MEDICATION_START_DATE]
        }
        
        if userMedication[PF_MEDICATION_END_DATE] != nil {
            form.formRow(withTag: "endDate").value = userMedication[PF_MEDICATION_START_DATE]
        }
        
        if userMedication[PF_MEDICATION_REGULER] != nil {
            if (userMedication[PF_MEDICATION_REGULER] as AnyObject).isEqual(false) {
                form.formRow(withTag: "date").value = userMedication[PF_MEDICATION_START_DATE]
            }
        }
        
        if userMedication[PF_MEDICATION_REGULER] != nil {
            form.formRow(withTag: "regulerMedicationEnable").value = userMedication[PF_MEDICATION_REGULER]
        }
        
        if userMedication[PF_MEDICATION_REMINDER] != nil {
            form.formRow(withTag: "reminderEnable").value = userMedication[PF_MEDICATION_REMINDER]
        }
        
        if userMedication[PF_MEDICATION_TIME] != nil {
            
            var timeList = [Date]()
            timeList.extend(userMedication[PF_MEDICATION_TIME] as! [Date]!)
            
            var tag = "Time"
            var timeValue: Date
            var section = form.formSection(at: 2)
            
            for index = 0 ; index < timeList.count; index += 1 {
                tag = tag + "\(index)"
                timeValue = timeList[index] as Date
                var row = XLFormRowDescriptor(tag: tag , rowType: XLFormRowDescriptorTypeTimeInline, title: "Time")
                row?.value = timeValue
                section?.addFormRow(row)
                timeListWithTag[tag] = timeValue
            }
            
           // NSLog("---- INDEX --------- \(timeListWithTag) ---- \(index)")
        }

    }
    
    func saveUserMedication() {
        
        userMedication[PF_MEDICATION_USER] = user
        
        if form.formRow(withTag: "name").value != nil {
            userMedication[PF_MEDICATION_NAME] = form.formRow(withTag: "name").value
        }
        
        if form.formRow(withTag: "description").value != nil {
            userMedication[PF_MEDICATION_DESCRITION] = form.formRow(withTag: "description").value
        }
        
        if form.formRow(withTag: "dose").value != nil {
            userMedication[PF_MEDICATION_DOSE] = form.formRow(withTag: "dose").value
        }
        
        if form.formRow(withTag: "note").value != nil {
            userMedication[PF_MEDICATION_NOTE] = form.formRow(withTag: "note").value
        }
        
        if form.formRow(withTag: "regulerMedicationEnable").value != nil {
            userMedication[PF_MEDICATION_REGULER] = form.formRow(withTag: "regulerMedicationEnable").value
        }
        
        if (form.formRow(withTag: "regulerMedicationEnable").value as AnyObject).isEqual(true) {
            userMedication[PF_MEDICATION_START_DATE] = form.formRow(withTag: "startDate").value
        } else {
            userMedication[PF_MEDICATION_START_DATE] = form.formRow(withTag: "date").value
        }
        
        if form.formRow(withTag: "endDate").value != nil {
            userMedication[PF_MEDICATION_END_DATE] = form.formRow(withTag: "endDate").value
        }
        
        if form.formRow(withTag: "reminderEnable").value != nil {
            userMedication[PF_MEDICATION_REMINDER] = form.formRow(withTag: "reminderEnable").value
        }
        
        if timeListWithTag.count > 0 {
            var timeList: [Date] = []
            for (key,timeValue) in timeListWithTag {
                 timeList.append(timeValue as Date)
            }
           userMedication[PF_MEDICATION_TIME] = timeList
        }
        
        userMedication.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                ProgressHUD.showSuccess("Saved")
                NSLog("------ Save data ------ . \(self.userMedication)")
            } else {
                NSLog("------ Error ------ . \(error)")
                
                ProgressHUD.showError("Network error")
            }
        })
    }

}
