//
//  Utilities.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Utilities {
    
    class func loginUser(_ target: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC = storyboard.instantiateViewController(withIdentifier: "navigationVC") as! UINavigationController
        target.present(welcomeVC, animated: true, completion: nil)
        
    }
    
    class func postNotification(_ notification: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: notification), object: nil)
    }
    
    class func timeElapsed(_ seconds: TimeInterval) -> String {
        var elapsed: String
        if seconds < 60 {
            elapsed = "Just now"
        }
        else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let suffix = (minutes > 1) ? "mins" : "min"
            elapsed = "\(minutes) \(suffix) ago"
        }
        else if seconds < 24 * 60 * 60 {
            let hours = Int(seconds / (60 * 60))
            let suffix = (hours > 1) ? "hours" : "hour"
            elapsed = "\(hours) \(suffix) ago"
        }
        else {
            let days = Int(seconds / (24 * 60 * 60))
            let suffix = (days > 1) ? "days" : "day"
            elapsed = "\(days) \(suffix) ago"
        }
        return elapsed
    }
    
    class func stringDateFormate(_ date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .short
        
        return formatter.string(for: date)!
    }
    
    
    class func getPrivacyString(_ privacy: Int) -> String {
        
        var PrivacyStr = String()
        
        if privacy == PUBLIC {
            PrivacyStr = "Public"
        } else if privacy == GROUP {
            PrivacyStr = "Group"
        } else if privacy == NETWORK {
            PrivacyStr = "Network"
        } else if privacy == ONLY_ME {
            PrivacyStr = "Only me"
        }
        
        return PrivacyStr
    }
    
    class func getPrivacyInt(_ privacy: String) -> Int {
        
        var PrivacyInt = Int()
        
        if privacy == "Public" {
            PrivacyInt = PUBLIC
        } else if privacy == "Group" {
            PrivacyInt = GROUP
        } else if privacy == "Network" {
            PrivacyInt = NETWORK
        } else if privacy == "Only me" {
            PrivacyInt = ONLY_ME
        }
        
        return PrivacyInt
    }
    
    class func durationCalculation(_ date: Date) -> Int {
        
        
        let calendar = Calendar.current
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        
        return (minutes + (hour * 60))
    }
    
    class func getHrMinString(_ time: Int) -> String {
        var timestr = ""
        
        if time > 60 {
            let hr = Int(time)/60
            let min = Int(time)%60
            timestr = "\(hr) hr : \(min) min"
        } else {
            timestr =  String(time) + " min"
        }
        
        return timestr
    }
    
    class func convertDurationToCalender(_ duration: Int) -> Date {
        
        
        let calendar = Calendar.current
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: Date())
        components.hour = duration/60
        components.minute = duration%60
        let newDate = calendar.dateFromComponents(components)
       
        return newDate!
    }
    
    class func calculateAge (_ birthday: Date) -> NSNumber {
        
        var userAge : NSInteger = 0
        var calendar : Calendar = Calendar.current
        var unitFlags : NSCalendar.Unit = NSCalendar.Unit.CalendarUnitYear | NSCalendar.Unit.CalendarUnitMonth | NSCalendar.Unit.CalendarUnitDay
        var dateComponentNow : DateComponents = (calendar as NSCalendar).components(unitFlags, from: Date())
        var dateComponentBirth : DateComponents = (calendar as NSCalendar).components(unitFlags, from: birthday)
        
        if ( (dateComponentNow.month! < dateComponentBirth.month!) ||
            ((dateComponentNow.month! == dateComponentBirth.month!) && (dateComponentNow.day! < dateComponentBirth.day!))
            )
        {
            return dateComponentNow.year - dateComponentBirth.year - 1
        }
        else {
            return dateComponentNow.year - dateComponentBirth.year
        }
    }
}

