//
//  DietDiaryViewController.swift
//  ega
//
//  Created by Runa Alam on 17/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class DietDiaryViewController: XLFormViewController {

    @IBOutlet weak var addEditButton: UIBarButtonItem!
    var user: PFUser = PFUser()
    var userDietDiary: PFObject = PFObject(className: PF_DIETDIARY_CLASS_NAME)
    var mealList: [PFObject]! = []
    var mealDictionary = [String: Int]()
    var totalSection = 0
    var selectedDate = Date()
    
    fileprivate enum Tags : String {
        
        case Date = "date"
        case Consumed = "totalConsumed"
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
        
        form = XLFormDescriptor(title: "Diet Diary")
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
        totalSection += 1
        
        //Date
        row = XLFormRowDescriptor(tag: Tags.Date.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title:"Date")
       // row.value = NSDate.new()
        row.cellConfigAtConfigure["maximumDate"] = Date()
        section.addFormRow(row)
       
        self.form = form
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == "date" {
            NSLog("---- section count \(form.formSections.count)")
            if form.formSections.count > totalSection {
                /*self.form.removeFormSectionAtIndex(UInt(self.form.formSections.count - 1))
                self.form.removeFormSectionAtIndex(UInt(self.form.formSections.count - 1))
                self.form.removeFormSectionAtIndex(UInt(self.form.formSections.count - 1))
                self.form.removeFormSectionAtIndex(UInt(self.form.formSections.count - 1))
                self.form.removeFormSectionAtIndex(UInt(self.form.formSections.count - 1))*/
               
                NSLog("********** total section ********* \(form.formSections.count)")
                
                for var i = form.formSections.count - Int(1) ; i >= totalSection ; i -= 1 {
                    self.form.removeFormSection(at: UInt(i))
                    NSLog("********** INDEX NUMBER ********* \(i)")
                }
                
                
            }
            self.loadDietDiary(formRow.value as! Date)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user != PFUser.current() {
            addEditButton.isEnabled = false
        }
        loadMealList()
        form.formRow(withTag: "date").value = selectedDate
        loadDietDiary(form.formRow(withTag: "date").value as! Date)
       // loadDietDiary(selectedDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       self.loadDietDiary(form.formRow(withTag: "date").value as! Date)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadMealList() {
        
        var query = PFQuery(className: PF_MEALLIST_CLASS_NAME)
        query?.whereKey(PF_MEALLIST_USER, equalTo: user )
        query?.order(byAscending: PF_MEALLIST_MEAL_NAME)
        //mealList = query.findObjects() as! [PFObject]
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.mealList.removeAll()
                self.mealList.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
                
                if self.mealList.count > 0 {
                    for meal in self.mealList {
                        var key = meal[PF_MEALLIST_MEAL_NAME] as! String
                        self.mealDictionary[key] = meal[PF_MEALLIST_MEAL_KILOJOULS] as? Int
                    }
                }
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    func loadDietDiary(_ date: Date) {
        
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
        
        var query = PFQuery(className: PF_DIETDIARY_CLASS_NAME)
        query?.whereKey(PF_DIETDIARY_USER, equalTo: user)
        query?.whereKey(PF_DIETDIARY_DATE, lessThan: dateArg2)
        query?.whereKey(PF_DIETDIARY_DATE, greaterThan: dateArg)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                
                self.userDietDiary = (object! as PFObject)
                
                var breakFastList = [String]()
                if self.userDietDiary[PF_DIETDIARY_BREAKFAST_ITEMS] != nil {
                    breakFastList.extend(self.userDietDiary[PF_DIETDIARY_BREAKFAST_ITEMS] as! [String])
                }
                
                var lunchItemLst = [String]()
                if self.userDietDiary[PF_DIETDIARY_LUNCH_ITEMS] != nil {
                    lunchItemLst.extend(self.userDietDiary[PF_DIETDIARY_LUNCH_ITEMS] as![String])
                }
                
                var dinnerList = [String]()
                if self.userDietDiary[PF_DIETDIARY_DINNER_ITEMS] != nil {
                    dinnerList.extend(self.userDietDiary[PF_DIETDIARY_DINNER_ITEMS] as![String])
                }
                
                var snackList = [String]()
                if self.userDietDiary[PF_DIETDIARY_SNACK_ITEMS] != nil {
                    snackList.extend(self.userDietDiary[PF_DIETDIARY_SNACK_ITEMS] as![String])
                }
                
                if self.form.formSections.count == self.totalSection {
                    
                    if self.userDietDiary[PF_DIETDIARY_TOTAL_CONSUMED] != nil {
                        var section = XLFormSectionDescriptor.formSection(withTitle: "Totl Consumed")
                        self.form.addFormSection(section)
                        var row = XLFormRowDescriptor(tag: Tags.Consumed.rawValue, rowType:XLFormRowDescriptorTypeInfo, title: "Kilojouls")
                        row.value = self.userDietDiary[PF_DIETDIARY_TOTAL_CONSUMED]
                        section.addFormRow(row)
                    }
                    
                    if breakFastList.count > 0 {
                        
                        var section = XLFormSectionDescriptor.formSection(withTitle: "Breakfast Items")
                        self.form.addFormSection(section)
                        for item in breakFastList {
                            var tags = item as String
                            var row = XLFormRowDescriptor(tag: tags, rowType:XLFormRowDescriptorTypeInfo, title: tags)
                            row.value = self.mealDictionary[item]
                           // NSLog("--- item kilojouls---\(item)")
                            section.addFormRow(row)
                        }
                    }
                    
                    if lunchItemLst.count > 0 {
                        
                        var section = XLFormSectionDescriptor.formSection(withTitle: "Lunch Items")
                        self.form.addFormSection(section)
                        for item in lunchItemLst {
                            var tags = item as String
                            var row = XLFormRowDescriptor(tag: tags, rowType:XLFormRowDescriptorTypeInfo, title: tags)
                            row.value = self.mealDictionary[item]
                            section.addFormRow(row)
                        }
                    
                    }
                    
                    if dinnerList.count > 0 {
                            
                        var section = XLFormSectionDescriptor.formSection(withTitle: "Dinner Items")
                        self.form.addFormSection(section)
                        for item in dinnerList {
                            var tags = item as String
                            var row = XLFormRowDescriptor(tag: tags, rowType:XLFormRowDescriptorTypeInfo, title: tags)
                            row.value = self.mealDictionary[item]
                            section.addFormRow(row)
                        }
                    }
                    
                    if snackList.count > 0 {
                        
                        var section = XLFormSectionDescriptor.formSection(withTitle: "Snack Items")
                        self.form.addFormSection(section)
                        for item in lunchItemLst {
                            var tags = item as String
                            var row = XLFormRowDescriptor(tag: tags, rowType:XLFormRowDescriptorTypeInfo, title: tags)
                            row.value = self.mealDictionary[item]
                            section.addFormRow(row)
                        }
                    }
                }
            } else {
                self.showNoDataAction()
                println(error)
            }
        }
    }
    
    func showNoDataAction() {
        
        let message = NSLocalizedString("No Diet added for the selected date", comment: "")
        let okButtonTitle = NSLocalizedString("OK", comment: "")
        let alertCotroller = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { action in
           
        }
        
        // Add the actions.
        alertCotroller.addAction(okAction)
        
        present(alertCotroller, animated: true, completion: nil)
    
    }
}
