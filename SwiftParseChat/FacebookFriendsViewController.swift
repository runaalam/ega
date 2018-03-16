//
//  FacebookFriendsViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/6/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

protocol FacebookFriendsViewControllerDelegate {
    func didSelectFacebookUser(_ user: PFUser)
}

class FacebookFriendsViewController: UITableViewController {
    
    var users = [PFUser]()
    var delegate: FacebookFriendsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadFacebook()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Backend methods
    
    func loadFacebook() {
        if FBSession.active().isOpen == false {
            return
        }
        
        var request = FBRequest.forMyFriends()
        request?.start { (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                
                var fbIds = [String]()
                var userData = result as! [String : AnyObject]
                var fbUsersData: AnyObject! = userData["data"]
                if let fbUsers = fbUsersData as? [AnyObject] {
                    for fbUser in fbUsers {
                        fbIds.append(fbUser["id"] as! String)
                    }
                }
                
                var query = PFQuery(className: PF_USER_CLASS_NAME)
                query.whereKey(PF_USER_FACEBOOKID, containedIn: fbIds)
                query.order(byAscending: PF_USER_FULLNAME)
                query.limit = 1000
                query.findObjectsInBackground({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        self.users.removeAll(keepingCapacity: false)
                        self.users += objects as! [PFUser]!
                        self.tableView.reloadData()
                    } else {
                        ProgressHUD.showError("Network error")
                    }
                })
            } else {
                ProgressHUD.showError("Facebook request error")
            }
        }
    }
    
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
        cell.textLabel?.text = user[PF_USER_FULLNAME] as? String
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.didSelectFacebookUser(self.users[indexPath.row])
            }
        })
    }

}
