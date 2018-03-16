//
//  MedicationLogViewCellViewController.swift
//  ega
//
//  Created by Runa Alam on 19/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class MedicationLogViewController: XLFormViewController {

    var user: PFUser = PFUser()
    var userMedicationLog: PFObject = PFObject(className: PF_MEDICATION_LOG_CLASS_NAME)
    var medicationList: [PFObject]! = []
    var medicationStrList: [String] = []
    var medicationValueList: [Bool] = []
    var totalSection = 0
    var selectedDate = Date()
    
    fileprivate enum Tags : String {
        
        case Date = "date"
        case SaveButton = "saveButton"
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
        
        form = XLFormDescriptor(title: "Medication Log")
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
         totalSection += 1
        
        //Date
        row = XLFormRowDescriptor(tag: Tags.Date.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title:"Date")
        //row.value = NSDate.new()
        row.cellConfigAtConfigure["maximumDate"] = Date()
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == "date" {
            self.loadMedicationLog(formRow.value as! Date)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMedicationList()
        form.formRow(withTag: "date").value = selectedDate
        loadMedicationLog(form.formRow(withTag: "date").value as! Date)
        //loadMedicationLog(selectedDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         loadMedicationList()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadMedicationList() {
        var query = PFQuery(className: PF_MEDICATION_CLASS_NAME)
        query?.whereKey(PF_MEDICATION_USER, equalTo: user)
        query?.whereKey(PF_MEDICATION_REGULER, equalTo: true)
        query?.order(byAscending: PF_MEDICATION_NAME)
        //mealList = query.findObjects() as! [PFObject]
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.medicationList.removeAll()
                self.medicationList.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    func loadMedicationLog(_ date: Date) {
        
        NSLog(" ---- DIET DIARY DATE----  \(date)")
        var tmpDate = date
        var dateArg : Date?
        var cal = Calendar.current
        let timeZone = TimeZone(abbreviation: "GMT")
        cal.timeZone = timeZone!
        cal.rangeOfUnit(.DayCalendarUnit, startDate: &dateArg,
            interval: nil, forDate: tmpDate)
        
        NSLog(" ---- DIET DIARY DATE changed----  \(dateArg)")
        let dateArg2 = dateArg!.addingTimeInterval(60*60*24)
        
        NSLog(" ---- DIET DIARY DATE1 changed----  \(dateArg2)")
        
        var query = PFQuery(className: PF_MEDICATION_LOG_CLASS_NAME)
        query?.whereKey(PF_Medication_LOG_USER, equalTo: user)
        query?.whereKey(PF_Medication_LOG_DATE, lessThan: dateArg2)
        query?.whereKey(PF_Medication_LOG_DATE, greaterThan: dateArg)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                
                self.userMedicationLog = (object! as PFObject)
                
                if self.form.formSections.count == self.totalSection {
                    self.cretaeExistingSectionAndRow()
                    if self.user == PFUser.current() {
                        self.createSectionAndButton()
                    }
                } else if self.form.formSections.count > self.totalSection {
                    
                    //Delete previously created section, row and button
                    self.form.removeFormSection(at: UInt(2))
                    self.form.removeFormSection(at: UInt(1))
                    self.cretaeExistingSectionAndRow()
                    if self.user == PFUser.current() {
                        self.createSectionAndButton()
                    }
                }
                
            } else {
                self.userMedicationLog = PFObject(className: PF_MEDICATION_LOG_CLASS_NAME)
                
                if self.medicationList.count > 0 {
                    if self.form.formSections.count == self.totalSection {
                        self.createNewSectionAndRow()
                        if self.user == PFUser.current() {
                            self.createSectionAndButton()
                        }
                    } else if self.form.formSections.count > self.totalSection {
                        self.form.removeFormSection(at: UInt(2))
                        self.form.removeFormSection(at: UInt(1))
                        self.createNewSectionAndRow()
                        if self.user == PFUser.current() {
                            self.createSectionAndButton()
                        }
                    }
                } else {
                    self.showNoDataAction()
                }

               NSLog("*************** medicationlist size inside the query \(self.medicationList.count) **************")
                println(error)
            }
        }
    }
    
    func cretaeExistingSectionAndRow() {
        
        let section = XLFormSectionDescriptor.formSection(withTitle: "Medications")
        self.form.addFormSection(section)
        
        self.medicationStrList.removeAll()
        self.medicationValueList.removeAll()
        
        if self.userMedicationLog[PF_Medication_LOG_TAKEN_STRING] != nil {
            self.medicationStrList = self.userMedicationLog[PF_Medication_LOG_TAKEN_STRING] as! [String]
            
            NSLog("*********** Medication str list ***** \(medicationStrList)")
        }
        
        if self.userMedicationLog[PF_Medication_LOG_TAKEN_VALUE] != nil {
            self.medicationValueList = self.userMedicationLog[PF_Medication_LOG_TAKEN_VALUE] as! [Bool]
            NSLog("*********** Medication value list ***** \(medicationValueList)")
        }
        for index in 0  ..< self.medicationStrList.count {
            let tag = self.medicationStrList[index] as String
            let row = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeBooleanCheck, title: tag)
            row?.value = self.medicationValueList[index] as Bool
            section?.addFormRow(row)
        }
    }
    
    func createNewSectionAndRow() {
        
        //medication list section
        let section = XLFormSectionDescriptor.formSection(withTitle: "Medications")
        self.form.addFormSection(section)
        
        medicationStrList.removeAll()
        medicationValueList.removeAll()
        
        for medication in self.medicationList {
            let tag = medication[PF_MEDICATION_NAME] as! String
            medicationStrList.append(tag)
            let row = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeBooleanCheck, title: tag)
            //row.value = false
            section?.addFormRow(row)
            
        }
    }
    
    func createSectionAndButton() {
        
        let section = XLFormSectionDescriptor()
        self.form.addFormSection(section)
            
        let row = XLFormRowDescriptor(tag: Tags.SaveButton.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Save")
        row?.cellConfig["textLabel.textColor"] = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        row?.action.formSelector = #selector(MedicationLogViewController.saveButtonPressed(_:))
            section.addFormRow(row)
    }
    
    func saveButtonPressed(_ sender: XLFormRowDescriptor) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        } else {
            self.saveMedicationLog()
        }
        
        self.tableView.endEditing(true)
        self.deselectFormRow(sender)
    }
    
    func saveMedicationLog() {
        
        userMedicationLog[PF_Medication_LOG_USER] = user
        
        if form.formRow(withTag: "date").value != nil {
            userMedicationLog[PF_Medication_LOG_DATE] = form.formRow(withTag: "date").value
        }
        
        medicationValueList.removeAll()
        
        for medication in medicationStrList {
            if form.formRow(withTag: medication).value != nil {
                medicationValueList.append(form.formRow(withTag: medication).value as! Bool)
            } else {
                medicationValueList.append(false)
            }
        }
        
        if medicationStrList.count > 0{
            userMedicationLog[PF_Medication_LOG_TAKEN_STRING] = medicationStrList
            userMedicationLog[PF_Medication_LOG_TAKEN_VALUE]  = medicationValueList
        }
        
        userMedicationLog.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                ProgressHUD.showSuccess("Saved")
                NSLog("------ Save data ------ . \(self.userMedicationLog)")
            } else {
                NSLog("------ Error ------ . \(error)")
                
                ProgressHUD.showError("Network error")
            }
        })
    }
    
    func showNoDataAction() {
        
        let message = NSLocalizedString("No Medication added to list", comment: "")
        let okButtonTitle = NSLocalizedString("OK", comment: "")
        let alertCotroller = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { action in
            
        }
        
        // Add the actions.
        alertCotroller.addAction(okAction)
        
        present(alertCotroller, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let MedicationListVC = segue.destinationViewController.topViewController as? MedicationListViewController {
            if "MedicationList" == segue.identifier {
                MedicationListVC.user = self.user
            }
        }
    }

}
