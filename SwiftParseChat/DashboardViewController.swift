//
//  DashboardViewController.swift
//  ega
//
//  Created by Runa Alam on 22/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class DashboardViewController: UITableViewController, PopUpPickerViewDelegate {

    
    var pickerView: PopUpPickerView!
    var selectedDate = Date()
    var medications: [String]! = []
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calorieBurnLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var medicationTakenLabel: UILabel!
    @IBOutlet weak var medicationSkipedLabel: UILabel!
    @IBOutlet weak var kilojoulsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configPickerView()

        loadMedications()
        self.updateDateLabel(Date())
        loadActivityInfo(Date())
        loadMedicationInfo(Date())
        loadDietInfo(Date())
    }
    
    @IBAction func dateButtonPressed(_ sender: AnyObject) {
        
        DatePickerDialog().show(doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: "Date", datePickerMode: .Date) {
            (date) -> Void in
            self.selectedDate = date
            self.updateDateLabel(date)
            self.loadActivityInfo(date)
            self.loadMedicationInfo(date)
            self.loadDietInfo(date)
        }
    }

    func configPickerView() {
        
        pickerView = PopUpPickerView()
        pickerView.delegate = self
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(pickerView)
        } else {
            self.view.addSubview(pickerView)
        }
    }
    
    func updateDateLabel(_ date: Date) {
        
        //let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: date)
        dateLabel.text = "\(dateString)"
    }

    
    func loadActivityInfo(_ date: Date) {
        
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
        
        var query = PFQuery(className: PF_USER_ACTIVITYLOG_CLASS_NAME)
        query?.whereKey(PF_USER_ACTIVITYLOG_USER, equalTo: PFUser.current())
        query?.whereKey(PF_USER_ACTIVITYLOG_DATE, lessThan: dateArg2)
        query?.whereKey(PF_USER_ACTIVITYLOG_DATE, greaterThan: dateArg)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                var totalCalorie = 0
                var totalDuration = 0
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var activity = Activity(activity: object)
                        totalCalorie = +Int(activity.caloriBurn!)
                        totalDuration = +Int(activity.duration!)
                    }
                    self.tableView.reloadData()
                    self.calorieBurnLabel.text = "\(totalCalorie)"
                    self.durationLabel.text = Utilities.getHrMinString(totalDuration)
                }
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    func loadMedications() {
        var query = PFQuery(className: PF_MEDICATION_CLASS_NAME)
        query?.whereKey(PF_MEDICATION_USER, equalTo: PFUser.current())
        query?.order(byAscending: PF_MEDICATION_NAME)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.medications.append(object[PF_MEDICATION_NAME] as! String)
                    }
                }
                
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }

    
    func loadMedicationInfo(_ date: Date){
        
        NSLog(" ---- MEDICATION DIARY DATE----  \(date)")
        var tmpDate = date
        var dateArg : Date?
        var cal = Calendar.current
        let timeZone = TimeZone(abbreviation: "GMT")
        cal.timeZone = timeZone!
        cal.rangeOfUnit(.DayCalendarUnit, startDate: &dateArg,
            interval: nil, forDate: tmpDate)
        
        NSLog(" ---- MEDICATION DATE changed----  \(dateArg)")
        let dateArg2 = dateArg!.addingTimeInterval(60*60*24)
        
        NSLog(" ---- MEDICATION DATE1 changed----  \(dateArg2)")
        
        var query = PFQuery(className: PF_MEDICATION_LOG_CLASS_NAME)
        query?.whereKey(PF_Medication_LOG_USER, equalTo: PFUser.current())
        query?.whereKey(PF_Medication_LOG_DATE, lessThan: dateArg2)
        query?.whereKey(PF_Medication_LOG_DATE, greaterThan: dateArg)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                var obj = object! as PFObject
                var mediStr = obj[PF_Medication_LOG_TAKEN_STRING] as! [String]
                var mediValue = obj[PF_Medication_LOG_TAKEN_VALUE] as! [Bool]
                var takenStr = ""
                var skipedStr = ""
                for var i = 0 ; i < mediStr.count ; i++ {
                    if mediValue[i] == true {
                        takenStr = takenStr + mediStr[i] + ", "
                    } else  {
                        skipedStr = skipedStr + mediStr[i] + ", "
                    }
                }
                if takenStr.isEmpty {
                    self.medicationTakenLabel.text = "No medication"
                } else {
                    self.medicationTakenLabel.text = takenStr
                }
                
                if skipedStr.isEmpty {
                    self.medicationSkipedLabel.text = "No medication"
                } else {
                    self.medicationSkipedLabel.text = skipedStr
                }
                
                NSLog("*************** Medication OBJECT  ************** \(object)")
            } else {
                
                NSLog("*************** medicationList inside the query ************** \(self.medications.count)")
                self.medicationTakenLabel.text = "No medication"
                var mediStr = ""
                for item in self.medications {
                   mediStr = mediStr + "\(item as String), "
                }
                self.medicationSkipedLabel.text = mediStr
                println(error)
            }
        }
    }
    
    func loadDietInfo(_ date: Date) {
        
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
                var obj = object! as PFObject
                self.kilojoulsLabel.text = "\(obj[PF_DIETDIARY_TOTAL_CONSUMED])"
                NSLog(" *************** OBJECT ********************\n \(object) \n *************")
                
            } else {
                println(error)
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let activityVC = segue.destinationViewController.topViewController as? ActivityLogViewController {
            if "ActivityLog" == segue.identifier {
                activityVC.user = PFUser.currentUser()
                activityVC.selectedDate = self.selectedDate
            }
        }
        
        if let medicationVC = segue.destinationViewController.topViewController as? MedicationLogViewController {
            if "MedicationLog" == segue.identifier {
                medicationVC.user = PFUser.currentUser()
                medicationVC.selectedDate = self.selectedDate
            }
        }
        
        if let dietVC = segue.destinationViewController.topViewController as? DietDiaryViewController {
            if "DietLog" == segue.identifier{
                dietVC.user = PFUser.currentUser()
                dietVC.selectedDate = self.selectedDate
            }
        }
    }
}
