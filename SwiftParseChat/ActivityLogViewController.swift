//
//  ActivityLogViewController.swift
//  ega
//
//  Created by Runa Alam on 19/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ActivityLogViewController: UIViewController, UITableViewDelegate, PopUpPickerViewDelegate {

    var userActivities: [Activity] = []
    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var totalCaloriBurnLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var userActivityLog: [PFObject]! = []
    var user: PFUser = PFUser()
    var pickerView: PopUpPickerView!
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user != PFUser.current() {
            addButton.isEnabled = false
        }
        configPickerView()
        self.updateDateLabel(selectedDate)
        loadUserActivities(selectedDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateDateLabel(selectedDate)
        loadUserActivities(selectedDate)    }
    @IBAction func datePickerPressed(_ sender: AnyObject) {
        
        DatePickerDialog().show(doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: "Date", datePickerMode: .Date) {
            (date) -> Void in
            
            self.updateDateLabel(date)
            self.loadUserActivities(date)
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
    
    func loadUserActivities(_ date: Date) {
        
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
        query?.whereKey(PF_USER_ACTIVITYLOG_USER, equalTo: user)
        query?.whereKey(PF_USER_ACTIVITYLOG_DATE, lessThan: dateArg2)
        query?.whereKey(PF_USER_ACTIVITYLOG_DATE, greaterThan: dateArg)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.userActivities.removeAll()
                var totalCalorie = 0
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var activity = Activity(activity: object)
                        totalCalorie = +Int(activity.caloriBurn!)
                        self.userActivities.append(activity)
                    }
                    self.tableView.reloadData()
                    self.totalCaloriBurnLabel.text = "\(totalCalorie)"
                }
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("---- Activity Count ------ \(self.userActivities.count)")
        
        return userActivities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityLogCell", for: indexPath) as! ActivityLogCell
        
        let activity = userActivities[indexPath.row]
        cell.useActivity(activity)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let activityVC = segue.destinationViewController.topViewController as? AddActivityViewController {
            
            if "SelectedActivity" == segue.identifier {
                if let path = tableView.indexPathForSelectedRow {
                    let activity = userActivities[path.row]
                    activityVC.userActivityLog = activity.activity!
                    activityVC.user = self.user
                    
                }
            } else if "AddActivity" == segue.identifier {
                let activity = PFObject(className: PF_USER_ACTIVITYLOG_CLASS_NAME)
                activityVC.userActivityLog = activity
                activityVC.user = self.user
            }
        }
    }
}
