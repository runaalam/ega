//
//  AddressBookViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/6/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import AddressBook
import MessageUI

protocol AddressBookViewControllerDelegate {
    func didSelectAddressBookUser(_ user: PFUser)
}

class AddressBookViewController: UITableViewController, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    var users1 = [APContact]()
    var users2 = [PFUser]()
    var indexSelected: IndexPath!
    var delegate: AddressBookViewControllerDelegate!
    
    // activity: UIActivityIndicatorView
    
    let addressBook = APAddressBook()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddressBookViewController.cleanup), name: NSNotification.Name(rawValue: NOTIFICATION_USER_LOGGED_OUT), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            // Load address book
            self.addressBook.fieldsMask = APContactField.Default | APContactField.Emails

            self.addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
            self.addressBook.loadContacts({ (contacts: [AnyObject]!, error: NSError!) -> Void in
                // TODO: Add actiivtyIndicator
                // self.activity.stopAnimating()
                self.users1.removeAll(keepingCapacity: false)
                if let contacts = contacts as? [APContact] {
                    for contact in contacts {
                        self.users1.append(contact)
                    }
                    self.loadUsers()
                } else if error != nil {
                    ProgressHUD.showError("Error loading contacts")
                    println(error)
                }
            })
        }
        else {
            Utilities.loginUser(self)
        }
    }
    
    // MARK: - User actions
    
    func cleanup() {
        users1.removeAll(keepingCapacity: false)
        users2.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
    }
    
    func loadUsers() {
        var emails = [String]()
        
        for user in users1 {
            if let userEmails = user.emails {
                emails += userEmails as! [String]
            }
        }
        
        var user = PFUser.current()
        
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query?.whereKey(PF_USER_OBJECTID, notEqualTo: user?.objectId)
        query?.whereKey(PF_USER_EMAILCOPY, containedIn: emails)
        query?.order(byAscending: PF_USER_FULLNAME)
        query?.limit = 1000
        query.findObjectsInBackground { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users2.removeAll(keepingCapacity: false)
                for user in objects as! [PFUser]! {
                    self.users2.append(user)
                    self.removeUser(user[PF_USER_EMAILCOPY] as! String)
                }
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
    }
    
    func removeUser(_ removeEmail: String) {
        var removeUsers = [APContact]()
        
        for user in users1 {
            if let userEmails = user.emails as? [String] {
                for email in userEmails {
                    if email == removeEmail {
                        removeUsers.append(user)
                        break
                    }
                }
            }
        }
        
        let filtered = self.users1.filter { !contains(removeUsers, $0) }
        self.users1 = filtered
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users2.count
        }
        if section == 1 {
            return users1.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && users2.count > 0 {
            return "Registered users"
        }
        if section == 1 && users1.count > 0 {
            return "Non-registered users"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        
        if indexPath.section == 0 {
            let user = users2[indexPath.row]
            cell.textLabel?.text = user[PF_USER_FULLNAME] as? String
            cell.detailTextLabel?.text = user[PF_USER_EMAILCOPY] as? String
        }
        else if indexPath.section == 1 {
            let user = users1[indexPath.row]
            let email = user.emails.first as? String
            let phone = user.phones.first as? String
            cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
            cell.detailTextLabel?.text = (email != nil) ? email : phone
        }
        
        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.dismiss(animated: true, completion: { () -> Void in
                if self.delegate != nil {
                    self.delegate.didSelectAddressBookUser(self.users2[indexPath.row])
                }
            })
        }
        else if indexPath.section == 1 {
            self.indexSelected = indexPath
            self.inviteUser(self.users1[indexPath.row])
        }
    }
    
    // MARK: - Invite helper method
    
    func inviteUser(_ user: APContact) {
        let emailsCount = count(user.emails)
        let phonesCount = count(user.phones)
        
        if emailsCount > 0 && phonesCount > 0 {
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Email invitation", "SMS invitation")
            actionSheet.show(from: (self.tabBarController?.tabBar)!)
        } else if emailsCount > 0 && phonesCount == 0 {
            self.sendMail(user)
        } else if emailsCount == 0 && phonesCount > 0 {
            self.sendSMS(user)
        } else {
            ProgressHUD.showError("Contact has no email or phone number")
        }
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            let user = users1[indexSelected.row]
            if buttonIndex == 1 {
                self.sendMail(user)
            } else if buttonIndex == 2 {
                self.sendSMS(user)
            }
        }
    }
    
    // MARK: - Mail sending method
    
    func sendMail(_ user: APContact) {
        if MFMailComposeViewController.canSendMail() {
            let mailCompose = MFMailComposeViewController()
            // TODO: Use one email rather than all emails
            mailCompose.setToRecipients(user.emails as! [String]!)
            mailCompose.setSubject("")
            mailCompose.setMessageBody(MESSAGE_INVITE, isHTML: true)
            mailCompose.mailComposeDelegate = self
            self.present(mailCompose, animated: true, completion: nil)
        } else {
            ProgressHUD.showError("Email not configured")
        }
    }
    
    // MARK: - MailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController!, didFinishWith result: MFMailComposeResult, error: Error!) {
        if result.value == MFMailComposeResult.sent.value {
            ProgressHUD.showSuccess("Invitation email sent successfully")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SMS sending method
    
    func sendSMS(_ user: APContact) {
        if MFMessageComposeViewController.canSendText() {
            let messageCompose = MFMessageComposeViewController()
            // TODO: Use primary phone rather than all numbers
            messageCompose.recipients = user.phones as! [String]!
            messageCompose.body = MESSAGE_INVITE
            messageCompose.messageComposeDelegate = self
            self.present(messageCompose, animated: true, completion: nil)
        } else {
            ProgressHUD.showError("SMS cannot be sent")
        }
    }
    
    // MARK: - MessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        if result.value == MessageComposeResult.sent.value {
            ProgressHUD.showSuccess("Invitation SMS sent successfully")
        }
        self.dismiss(animated: true, completion: nil)
    }

}