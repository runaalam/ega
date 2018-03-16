//
//  SelectSingleViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/5/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

protocol SelectSingleViewControllerDelegate {
    func didSelectSingleUser(_ user: PFUser)
}

class SelectSingleViewController: UITableViewController, UISearchBarDelegate {

    var users = [PFUser]()
    var delegate: SelectSingleViewControllerDelegate!
    var child: PFUser = PFUser()
    var guardian: PFUser = PFUser()
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        //self.searchBar.delegate = self
        self.loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Backend methods
    
    func loadUsers() {
       /* let user = PFUser.currentUser()
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user.objectId)
        query.orderByAscending(PF_USER_FULLNAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users.removeAll(keepCapacity: false)
                self.users += objects as! [PFUser]!
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }*/
        
        var query = PFQuery(className: PF_NETWORK_CLASS_NAME)
        query?.whereKey(PF_NETWORK_USER, equalTo: PFUser.current())
        query?.includeKey(PF_NETWORK_USER_GURDIAN)
        query?.includeKey(PF_NETWORK_USER_CHILD)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil || object != nil {
                self.users.removeAll()
                var child = object![PF_NETWORK_USER_CHILD] as! PFUser
                var guardian = object![PF_NETWORK_USER_GURDIAN] as! PFUser
                self.users.append(guardian)
                self.users.append(child)
                 //self.users += object![PF_NETWORK_USER_CHILD] as! [PFUser]!
                // self.users += object![PF_NETWORK_USER_GURDIAN] as! [PFUser]!
                 self.tableView.reloadData()
            } else {
                self.showConnectionAlert()
                NSLog("------ Error ------ . \(error)")
                ProgressHUD.showError("Network error")
            }
        }
    }
    
   /* func searchUsers(searchLower: String) {
        let user = PFUser.currentUser()
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user.objectId)
        query.whereKey(PF_USER_FULLNAME_LOWER, containsString: searchLower)
        query.orderByAscending(PF_USER_FULLNAME)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users.removeAll(keepCapacity: false)
                self.users += objects as! [PFUser]!
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
            
        }
    }*/
    
    // MARK: - User actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
        
        if users[0].objectId == user.objectId {
            cell.textLabel?.text = "\(user[PF_USER_FULLNAME] as! String)" + " - (Guardian)"
        } else if users[1].objectId == user.objectId {
            cell.textLabel?.text = "\(user[PF_USER_FULLNAME] as! String)" + " - (Child)" 
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.didSelectSingleUser(self.users[indexPath.row])
            }
        })
    }
    
    // MARK: - UISearchBar Delegate
    
   /* func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            self.searchUsers(searchText.lowercaseString)
        } else {
            self.loadUsers()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBarCancelled()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelled() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        self.loadUsers()
    }*/
    
    func showConnectionAlert() {
        let title = NSLocalizedString("Sorry", comment: "")
        let message = NSLocalizedString("No Connection assign yet", comment: "")
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The simple alert's cancel action occured.")
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        // dismissViewControllerAnimated(true, completion: nil)
        present(alertController, animated: false, completion: nil)
    }

}
