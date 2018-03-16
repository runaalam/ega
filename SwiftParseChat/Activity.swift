//
//  Activity.swift
//  ega
//
//  Created by Runa Alam on 24/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Activity {
    
    var activityID: String?
    var activityName: String?
    var date: Date!
    var duration: Int?
    var caloriBurn: NSNumber?
    var activity: PFObject?
    
    init() {}
    
    init(activity: PFObject) {
        
        activityID      = activity[PF_USER_ACTIVITYLOG_OBJECTID] as? String
        activityName    = activity[PF_USER_ACTIVITYLOG_NAME] as? String
        date            = activity[PF_USER_ACTIVITYLOG_DATE] as! Date
        duration        = activity[PF_USER_ACTIVITYLOG_DURATION] as? Int
        caloriBurn      = activity[PF_USER_ACTIVITYLOG_CALORIE_BURN] as? NSNumber
        self.activity   = activity
    }
}
