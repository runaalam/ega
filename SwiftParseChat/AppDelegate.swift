//
//  AppDelegate.swift
//  SwiftParseChat
//
//  Created by Runa Alam on 27/05/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
// Parse and ParseFacebookUtils imported in SwiftParseChat-Bridging-Header.h

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // style the navigation bar
        let navColor = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = navColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // make the status bar white
        application.statusBarStyle = .lightContent
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("jyZjAm9bFF5VmmuFI6EpRQpg6TqqGO81ux0AdHE0", clientKey: "u7AUiQTj4hAAHX6l3Vj3c6lVb47aLL4VqlF0GnJC")
        // PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebook()
        
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let userNotificationTypes = (UIUserNotificationType.Alert |
                UIUserNotificationType.Badge |
                UIUserNotificationType.Sound)
            
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        //        FBLoginView.self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBAppCall.handleDidBecomeActive(with: PFFacebookUtils.session())
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Mark: - Facebook response
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBAppCall.handleOpen(url, sourceApplication: sourceApplication, with: PFFacebookUtils.session())
    }
    
    // Mark - Push Notification methods
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground { (succeeed: Bool, error: NSError!) -> Void in
            if error != nil {
                println("didRegisterForRemoteNotificationsWithDeviceToken")
                println(error)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        println("didFailToRegisterForRemoteNotificationsWithError")
        println(error)
    }
    
    // TODO: Rewrite this method with notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        let delay = 4.0 * Double(NSEC_PER_SEC)
//        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
//            MessagesViewController.refreshMessagesView()
//        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadMessages"), object: nil)
    }

}

