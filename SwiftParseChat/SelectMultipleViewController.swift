//
//  SelectSingleViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/5/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

protocol SelectMultipleViewControllerDelegate {
    func didSelectMultipleUsers(_ selectedUsers: [PFUser]!)
}

class SelectMultipleViewController: UITableViewController {

    var users = [PFUser]()
    var selection = [String]()
    var delegate: SelectMultipleViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Backend methods
    
    func loadUsers() {
        let user = PFUser.current()
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query?.whereKey(PF_USER_OBJECTID, notEqualTo: user?.objectId)
        query?.order(byAscending: PF_USER_FULLNAME)
        query?.limit = 1000
        query.findObjectsInBackground { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users.removeAll(keepingCapacity: false)
                self.users += objects as! [PFUser]!
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
    }
    
    // MARK: - User actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if self.selection.count == 0 {
            ProgressHUD.showError("No recipient selected")
        } else {
            self.dismiss(animated: true, completion: { () -> Void in
                var selectedUsers = [PFUser]()
                for user in self.users {
                    if contains(self.selection, user.objectId) {
                        selectedUsers.append(user)
                    }
                }
                selectedUsers.append(PFUser.current())
                self.delegate.didSelectMultipleUsers(selectedUsers)
            })
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 

        let user = self.users[indexPath.row]
        cell.textLabel?.text = user[PF_USER_FULLNAME] as? String
        
        let selected = contains(self.selection, user.objectId)
        cell.accessoryType = selected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.users[indexPath.row]
        let selected = contains(self.selection, user.objectId)
        if selected {
            if let index = find(self.selection, user.objectId) {
                self.selection.remove(at: index)
            }
        } else {
            self.selection.append(user.objectId)
        }
        
        self.tableView.reloadData()
    }

    
}
