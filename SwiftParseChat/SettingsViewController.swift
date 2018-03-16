//
//  SettingsTableViewController.swift
//  EGA
//
//  Created by Runa Alam on 20/04/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UIActionSheetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

       // configureLogouttSwitch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
  
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        self.logout()
    }
       
    func logout() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Log out")
            actionSheet.show(from: (self.tabBarController?.tabBar)!)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            PFUser.logOut()
            PushNotication.parsePushUserResign()
            Utilities.postNotification(NOTIFICATION_USER_LOGGED_OUT)
           // self.cleanup()
            Utilities.loginUser(self)
        }
    }
    
    // MARK: - User actions
    
   /* func cleanup() {
        userImageView.image = UIImage(named: "profile_blank")
        nameField.text = nil;
    }*/
        
}
