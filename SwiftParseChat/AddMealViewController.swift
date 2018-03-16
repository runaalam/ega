//
//  AddMealViewController.swift
//  ega
//
//  Created by Runa Alam on 10/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class AddMealViewController: XLFormViewController {
    
    var mealList: [PFObject]! = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    fileprivate enum Tags : String {
        
        case MealType = "mealType"
        case MealName = "mealName"
        case ServingSize = "servingSize"
        case Kilojouls = "kilojouls"
        case NoBreakfastRecord = "noBreakfastRecord"
        case NoLunchRecord = "noLunchRecord"
        case NoDinnerRecord = "noDinnerRecord"
        case NoSnackRecord = "noSnackRecord"
        
    }
    
    func initializeForm() {
        
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor

        form = XLFormDescriptor(title: "Add Meal")
        
        section = XLFormSectionDescriptor.formSection(withTitle: "Meal Details")
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: Tags.MealName.rawValue, rowType: XLFormRowDescriptorTypeText, title: "Meal Name")
        row.isRequired = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.ServingSize.rawValue, rowType: XLFormRowDescriptorTypeText, title: "Serving Size")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Kilojouls.rawValue, rowType: XLFormRowDescriptorTypeNumber, title: "Kilojouls")
        row.isRequired = true
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func formRowHasBeenRemoved(_ formRow: XLFormRowDescriptor!, at indexPath: IndexPath!) {
        super.formRowHasBeenRemoved(formRow, at: indexPath)
        
        if formRow.tag != nil {
            
            /*--- Delete from Database ---*/
            var mealObj: PFObject
            for meal in mealList {
                if meal.objectId == formRow.tag {
                    mealObj = meal as PFObject
                    mealObj.deleteInBackground(nil)
                    //NSLog("-- Remove --- \(formRow.tag)---- \(mealObj)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(AddMealViewController.savePressed(_:)))
        
        loadMealList()
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMealList() {
       
        var query = PFQuery(className: PF_MEALLIST_CLASS_NAME)
        query?.whereKey(PF_MEALLIST_USER, equalTo: PFUser.current() )
        query?.order(byAscending: PF_MEALLIST_MEAL_TYPE)
       // mealList = query.findObjects() as! [PFObject]
        
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.mealList.removeAll()
                self.mealList.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
            
            if self.mealList.count > 0 {
                //var secIndex = self.form.formSections.count
                var section = self.form.formSection(at: 0)
                section = XLFormSectionDescriptor.formSection(withTitle: "Meal list", sectionOptions:XLFormSectionOptions.canDelete)
                section.footerTitle = "you can swipe to delete meal item"
                self.form.addFormSection(section)
                
                for meal in self.mealList {
                    
                    if meal.objectId != nil {
                        var tags = meal.objectId as String
                        var row = XLFormRowDescriptor(tag: tags, rowType:XLFormRowDescriptorTypeInfo, title: meal[PF_MEALLIST_MEAL_NAME] as! String)
                        //row.value = meal[PF_MEALLIST_MEAL_NAME] as! String
                        section.addFormRow(row)
                        
                       // NSLog ("--- Tag & Value --- \(tags) --- \(row.value)")
                    }
                }
            }
        }
    }
    
    func savePressed(_ button: UIBarButtonItem) {
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        } else {
            saveUserMeal()
        }
        
        self.tableView.endEditing(true)
        
       // NSLog("******* Data *******  ****** \(userMealList)")
    }
    
    func saveUserMeal() {
        
        var userMealList: PFObject = PFObject(className: PF_MEALLIST_CLASS_NAME)
        userMealList[PF_MEALLIST_USER] = PFUser.current()
        
        if form.formRow(withTag: "mealName").value != nil {
            userMealList[PF_MEALLIST_MEAL_NAME] = form.formRow(withTag: "mealName").value
        }
        
        if form.formRow(withTag: "servingSize").value != nil {
            userMealList[PF_MEALLIST_MEAL_SERVING_SIZE] = form.formRow(withTag: "servingSize").value
        }
        
        if form.formRow(withTag: "kilojouls").value != nil {
            userMealList[PF_MEALLIST_MEAL_KILOJOULS] = form.formRow(withTag: "kilojouls").value
        }
        
        userMealList.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                ProgressHUD.showSuccess("Saved")
                NSLog("------ Save data ------ . \(userMealList)")
                
                if self.mealList.count > 0 {
                    var section = self.form.formSection(at: 1)
                    var tags = userMealList.objectId as String
                    var row = XLFormRowDescriptor(tag: tags, rowType:XLFormRowDescriptorTypeInfo, title: userMealList[PF_MEALLIST_MEAL_NAME] as! String)
                    section.addFormRow(row)
                } else {
                    self.loadMealList()
                }
            } else {
                NSLog("------ Error ------ . \(error)")
                
                ProgressHUD.showError("Network error")
            }
        })
    }
}
