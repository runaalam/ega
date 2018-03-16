//
//  DietViewController.swift
//  ega
//
//  Created by Runa Alam on 10/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class AddDietDiaryViewController: XLFormViewController, UIPopoverPresentationControllerDelegate {
    
    var userDietDiary: PFObject = PFObject(className: PF_DIETDIARY_CLASS_NAME)
    
    var mealList: [PFObject]! = []
    var mealDictionary = [String: Int]()
    var breakfastItems = [String]()
    var lunchItems = [String]()
    var dinnerItems = [String]()
    var snackItems = [String]()

    var breakkfastConsumed = 0
    var lunchConsumed = 0
    var dinnerConsumed = 0
    var snackConsumed = 0
    var totalConsumed = 0
    
    fileprivate enum Tags : String {
    
        case Button = "button"
        case AddMeal = "addMeal"
        case Date = "date"
        case MealConsmed = "mealConsmed"
        case BreakfastSelector = "breakfastSelector"
        case LunchSelector = "lunchSelector"
        case DinnerSelector = "dinnerSelector"
        case SnackSelector = "snackSelector"
        
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
    
        form = XLFormDescriptor(title: " Add Diet Diary")
        
        section = XLFormSectionDescriptor.formSection(withTitle: "Meal list")
        section.footerTitle = "Add your reguler meal to list"
        form.addFormSection(section)
        
        //Button
        row = XLFormRowDescriptor(tag: Tags.Button.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Add Item")
        row.cellConfig["textLabel.textColor"] = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        row.action.viewControllerStoryboardId = "AddMealToList"
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
        
        //Date
        row = XLFormRowDescriptor(tag: Tags.Date.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title:"Date")
        //row.value = NSDate.new()
        row.cellConfigAtConfigure["maximumDate"] = Date()
        section.addFormRow(row)
        
        /* ------ breakfast -------*/
        section = XLFormSectionDescriptor.formSection(withTitle: "Breakfast")
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.BreakfastSelector.rawValue, rowType:XLFormRowDescriptorTypeMultipleSelector, title:"Select breakfast items")
        section.addFormRow(row)
        
        /* ------ lunch -------*/
        section = XLFormSectionDescriptor.formSection(withTitle: "Lunch")
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.LunchSelector.rawValue, rowType:XLFormRowDescriptorTypeMultipleSelector, title:"Select lunch items")
        section.addFormRow(row)
        
        
        /* ------ dinner -------*/
        section = XLFormSectionDescriptor.formSection(withTitle: "Dinner")
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.DinnerSelector.rawValue, rowType:XLFormRowDescriptorTypeMultipleSelector, title:"Select dinner items")
        section.addFormRow(row)
        
        /* ------ snack -------*/
        section = XLFormSectionDescriptor.formSection(withTitle: "Snack")
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.SnackSelector.rawValue, rowType:XLFormRowDescriptorTypeMultipleSelector, title:"Select Snack items")
        section.addFormRow(row)
        self.form = form
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == "date" {
            NSLog(" ---- Date ---- \(formRow.value)")
            self.userDietDiary = PFObject(className: PF_DIETDIARY_CLASS_NAME)
            self.loadDietDiary(formRow.value as! Date)
        }
        
        if formRow.tag == "breakfastSelector" && formRow.value != nil{
            breakfastItems = formRow.value as! [String]
        }
        
        if formRow.tag == "lunchSelector" && formRow.value != nil{
            lunchItems = formRow.value as! [String]
        }

        if formRow.tag == "dinnerSelector" && formRow.value != nil{
            dinnerItems = formRow.value as! [String]
        }
        
        if formRow.tag == "snackSelector" && formRow.value != nil{
            snackItems = formRow.value as! [String]
        }
        if formRow.tag == "button" {
            self.loadMealList()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AddDietDiaryViewController.cancelPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(AddDietDiaryViewController.savePressed(_:)))
        
        loadMealList()
        //loadDietDiary(form.formRowWithTag("date").value as! NSDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadMealList()
        //self.loadDietDiary(form.formRowWithTag("date").value as! NSDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.saveDietDiary()
        }

        self.tableView.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadMealList() {
       
        var query = PFQuery(className: PF_MEALLIST_CLASS_NAME)
        query?.whereKey(PF_MEALLIST_USER, equalTo: PFUser.current() )
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
                    
                    /*---- Add row with selector options -----*/
                    var breakFastRow : XLFormRowDescriptor = self.form.formRow(withTag: Tags.BreakfastSelector.rawValue)
                    breakFastRow.disabled = false
                    breakFastRow.selectorOptions = self.mealDictionary.keys.array
                    
                    var lunchRow: XLFormRowDescriptor = self.form.formRow(withTag: Tags.LunchSelector.rawValue)
                    lunchRow.disabled = false
                    lunchRow.selectorOptions = self.mealDictionary.keys.array
                    
                    var dinnerRow: XLFormRowDescriptor = self.form.formRow(withTag: Tags.DinnerSelector.rawValue)
                    dinnerRow.disabled = false
                    dinnerRow.selectorOptions = self.mealDictionary.keys.array
                    
                    var snackRow: XLFormRowDescriptor = self.form.formRow(withTag: Tags.SnackSelector.rawValue)
                    snackRow.disabled = false
                    snackRow.selectorOptions = self.mealDictionary.keys.array
                    
                } else {
                    var breakFastRow : XLFormRowDescriptor = self.form.formRow(withTag: Tags.BreakfastSelector.rawValue)
                    breakFastRow.disabled = true
                    
                    var lunchRow: XLFormRowDescriptor = self.form.formRow(withTag: Tags.LunchSelector.rawValue)
                    lunchRow.disabled = true
                    
                    var dinnerRow: XLFormRowDescriptor = self.form.formRow(withTag: Tags.DinnerSelector.rawValue)
                    dinnerRow.disabled = true
                    
                    var snackRow: XLFormRowDescriptor = self.form.formRow(withTag: Tags.SnackSelector.rawValue)
                    snackRow.disabled = true
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
        query?.whereKey(PF_DIETDIARY_USER, equalTo: PFUser.current())
        query?.whereKey(PF_DIETDIARY_DATE, lessThan: dateArg2)
        query?.whereKey(PF_DIETDIARY_DATE, greaterThan: dateArg)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                   
                    self.userDietDiary = (object! as PFObject)
                    NSLog(" ---- LOADED DIET DIARY ----  \(self.userDietDiary)")
                    
                    if self.userDietDiary[PF_DIETDIARY_BREAKFAST_ITEMS] != nil {
                        self.form.formRow(withTag: "breakfastSelector").value = self.userDietDiary[PF_DIETDIARY_BREAKFAST_ITEMS]
                    }
                    
                    if self.userDietDiary[PF_DIETDIARY_LUNCH_ITEMS] != nil {
                        self.form.formRow(withTag: "lunchSelector").value = self.userDietDiary[PF_DIETDIARY_LUNCH_ITEMS]
                    }
                    
                    if self.userDietDiary[PF_DIETDIARY_DINNER_ITEMS] != nil {
                        self.form.formRow(withTag: "dinnerSelector").value = self.userDietDiary[PF_DIETDIARY_DINNER_ITEMS]
                    }
                    
                    if self.userDietDiary[PF_DIETDIARY_SNACK_ITEMS] != nil {
                        self.form.formRow(withTag: "snackSelector").value = self.userDietDiary[PF_DIETDIARY_SNACK_ITEMS]
                    }
                    self.tableView.reloadData()
                    NSLog("---- User Load Diet Diary in if ---- \(self.userDietDiary)")
                } else {
                    
                    if self.form.formRow(withTag: "breakfastSelector").value != nil {
                        self.form.formRow(withTag: "breakfastSelector").value = nil
                    }
                    
                    if self.form.formRow(withTag: "lunchSelector").value != nil {
                        self.form.formRow(withTag: "lunchSelector").value = nil
                    }
                    
                    if self.form.formRow(withTag: "dinnerSelector").value != nil {
                        self.form.formRow(withTag: "dinnerSelector").value = nil
                    }
                    
                    if self.form.formRow(withTag: "snackSelector").value != nil {
                        self.form.formRow(withTag: "snackSelector").value = nil
                    }
                    
                    self.tableView.reloadData()
                    
                    NSLog("---- User Load Diet Diary in else---- \(self.userDietDiary)")
                   // ProgressHUD.showError("No Diet added for the selected day")
                    println(error)
                }
        }
        
    }
    
    func saveDietDiary() {
        
        userDietDiary[PF_DIETDIARY_USER] = PFUser.current()
        
        if form.formRow(withTag: "date").value != nil {
            userDietDiary[PF_DIETDIARY_DATE] = form.formRow(withTag: "date").value
        }
        
        if breakfastItems.count > 0 {
            userDietDiary[PF_DIETDIARY_BREAKFAST_ITEMS] = breakfastItems
            
            for item in breakfastItems {
                breakkfastConsumed = breakkfastConsumed + mealDictionary[item]!
            }
            
            userDietDiary[PF_DIETDIARY_BREAKFAST_CONSUMED] = breakkfastConsumed
            totalConsumed = totalConsumed + breakkfastConsumed
        }
        
        if lunchItems.count > 0 {
            userDietDiary[PF_DIETDIARY_LUNCH_ITEMS] = lunchItems
            
            for item in lunchItems {
                lunchConsumed = lunchConsumed + mealDictionary[item]!
            }
            
            userDietDiary[PF_DIETDIARY_LUNCH_CONSUMED] = lunchConsumed
            totalConsumed = totalConsumed + lunchConsumed
        }
        
        if dinnerItems.count > 0 {
            userDietDiary[PF_DIETDIARY_DINNER_ITEMS] = dinnerItems
            
            for item in dinnerItems {
                dinnerConsumed = dinnerConsumed + mealDictionary[item]!
            }
            
            userDietDiary[PF_DIETDIARY_DINNER_CONSUMED] = dinnerConsumed
            totalConsumed = totalConsumed + dinnerConsumed
        }
        
        if snackItems.count > 0 {
            userDietDiary[PF_DIETDIARY_SNACK_ITEMS] = snackItems
            
            for item in snackItems {
                snackConsumed = snackConsumed + mealDictionary[item]!
            }
            
            userDietDiary[PF_DIETDIARY_SNACK_CONSUMED] = snackConsumed
            totalConsumed = totalConsumed + snackConsumed
        }
        
        if totalConsumed != 0 {
            userDietDiary[PF_DIETDIARY_TOTAL_CONSUMED] = totalConsumed
        }
        
        userDietDiary.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                ProgressHUD.showSuccess("Saved")
                NSLog("------ Save data ------ . \(self.userDietDiary)")
            } else {
                NSLog("------ Error ------ . \(error)")
                
                ProgressHUD.showError("Network error")
            }
        })
        NSLog("---- User Saved Diet Diary ---- \(userDietDiary)")
    }

}

