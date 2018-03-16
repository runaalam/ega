//
//  MedicineDetailsViewController.swift
//  EGA
//
//  Created by Runa Alam on 5/05/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

var medTimeList = [Date]()

class MedicineDetailsViewController: UITableViewController {

    @IBOutlet weak var medicineDetailsNavigation: UINavigationItem!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var timeList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        
        setupNotificationSettings()
        
        NotificationCenter.default.addObserver(self, selector: "handleModifyListNotification", name: NSNotification.Name(rawValue: "modifyListNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: "handleDeleteListNotification", name: NSNotification.Name(rawValue: "deleteListNotification"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK Configuration 
    
    func configureNavigationBar() {
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MedicineDetailsViewController.doneBarButtonItemClicked))
        
        medicineDetailsNavigation.setRightBarButton(doneBarButtonItem, animated: true)
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MedicineDetailsViewController.cancelBarButtonItemClicked))
        
        medicineDetailsNavigation.setLeftBarButton(cancelBarButtonItem, animated: true)
        
    }
    
    @IBAction func addMedicationTime(_ sender: AnyObject) {
        DatePickerDialog().show(doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: "Time", datePickerMode: .Time) {
            (date) -> Void in
            
            medTimeList.append(date)
            self.updateTimeLabel()
           
        }
        
    }
    
    func doneBarButtonItemClicked() {
        // Dismiss the keyboard by removing it as the first responder.
        
        navigationItem.setRightBarButton(nil, animated: true)
        
            
        for i in 0 ..< medTimeList.count {
                
            self.scheduleLocalNotification(medTimeList[i])
                
            NSLog("------ Med List: \(medTimeList[i]) ------ .")
                
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelBarButtonItemClicked() {
        // Dismiss the keyboard by removing it as the first responder.
        
        navigationItem.setLeftBarButton(nil, animated: true)
        
        showCancelActionSheet()
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
    
    func updateTimeLabel() {
        
        var str = ""
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        for i in 0 ..< medTimeList.count {
            
            if i != 0 {
                str += ", "
            }
            str += formatter.string(from: medTimeList[i])
            timeLabel.text = str
        }
    
    }
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.shared.currentUserNotificationSettings
        
        if (notificationSettings.types == UIUserNotificationType()){
            // Specify the notification types.
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            
            // Specify the notification actions.
            var justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "OK, got it"
            justInformAction.activationMode = UIUserNotificationActivationMode.background
            justInformAction.isDestructive = false
            justInformAction.isAuthenticationRequired = false
            
            var modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "Edit list"
            modifyListAction.activationMode = UIUserNotificationActivationMode.foreground
            modifyListAction.isDestructive = false
            modifyListAction.isAuthenticationRequired = true
            
            var trashAction = UIMutableUserNotificationAction()
            trashAction.identifier = "trashAction"
            trashAction.title = "Delete list"
            trashAction.activationMode = UIUserNotificationActivationMode.background
            trashAction.isDestructive = true
            trashAction.isAuthenticationRequired = true
            
            let actionsArray = NSArray(objects: justInformAction, modifyListAction, trashAction)
            let actionsArrayMinimal = NSArray(objects: trashAction, modifyListAction)
            
            // Specify the category related to the above actions.
            var medicationTimeReminderCategory = UIMutableUserNotificationCategory()
            medicationTimeReminderCategory.identifier = "medicationTimeReminderCategory"
            medicationTimeReminderCategory.setActions(actionsArray as [AnyObject] as [AnyObject], for: UIUserNotificationActionContext.Default)
            medicationTimeReminderCategory.setActions(actionsArrayMinimal as [AnyObject] as [AnyObject], for: UIUserNotificationActionContext.Minimal)
            
            
            let categoriesForSettings = NSSet(objects: medicationTimeReminderCategory)
            
            
            // Register the notification settings.
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as Set<NSObject>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
    func scheduleLocalNotification(_ date: Date) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = fixNotificationDate(date)
        localNotification.alertBody = "Hey, you must take medicine, remember?"
        localNotification.alertAction = "View List"
        
        localNotification.category = "medicationTimeReminderCategory"
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func fixNotificationDate(_ dateToFix: Date) -> Date {
        var dateComponets: DateComponents = Calendar.currentCalendar().components(NSCalendar.Unit.DayCalendarUnit | NSCalendar.Unit.MonthCalendarUnit | NSCalendar.Unit.YearCalendarUnit | NSCalendar.Unit.HourCalendarUnit | NSCalendar.Unit.MinuteCalendarUnit, fromDate: dateToFix)
        
        dateComponets.second = 0
        
        var fixedDate: Date! = Calendar.current.date(from: dateComponets)
        
        return fixedDate
    }
}
