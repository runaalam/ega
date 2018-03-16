//
//  DatePickerActionSheet.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 30/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import UIKit

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(_ date : Date?)
}

class PopDateViewController : UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate : DataPickerViewControllerDelegate?

    var currentDate : Date? {
        didSet {
            updatePickerCurrentDate()
        }
    }

    convenience init() {

        self.init(nibName: "PopDateViewController", bundle: nil)
    }

    fileprivate func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate
            }
        }
    }

    @IBAction func okAction(_ sender: AnyObject) {
        
        self.dismiss(animated: true) {
            
            let nsdate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(nsdate)
            
        }
    }
    
    override func viewDidLoad() {
       // configureDatePicker()
        
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(nil)
    }
    
    func configureDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        
        // Set min/max date for the date picker.
        // As an example we will limit the date between now and 7 days from now.
        let now = Date()
        datePicker.minimumDate = now
        
        let currentCalendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.day = 7
        
        let sevenDaysFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        datePicker.maximumDate = sevenDaysFromNow
        
        datePicker.minuteInterval = 2
        
       // datePicker.addTarget(self, action: "updateDatePickerLabel", forControlEvents: .ValueChanged)
        
       // updateDatePickerLabel()
    }

}
