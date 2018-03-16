//
//  PushNotification.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/22/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class PushNotication {
    
    class func parsePushUserAssign() {
        var installation = PFInstallation.current()
        installation?[PF_INSTALLATION_USER] = PFUser.current()
        installation.saveInBackground { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("parsePushUserAssign save error.")
            }
        }
    }
    
    class func parsePushUserResign() {
        var installation = PFInstallation.current()
        installation?.remove(forKey: PF_INSTALLATION_USER)
        installation.saveInBackground { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("parsePushUserResign save error")
            }
        }
    }
    
    class func sendPushNotification(_ groupId: String, text: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query?.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query?.whereKey(PF_MESSAGES_USER, equalTo: PFUser.current())
        query?.includeKey(PF_MESSAGES_USER)
        query?.limit = 1000
        
        var installationQuery = PFInstallation.query()
        installationQuery?.whereKey(PF_INSTALLATION_USER, matchesKey: PF_MESSAGES_USER, in: query)
        
        var push = PFPush()
        push.setQuery(installationQuery)
        push.setMessage(text)
        push.sendInBackground { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("sendPushNotification error")
            }
        }
    }
    
}
