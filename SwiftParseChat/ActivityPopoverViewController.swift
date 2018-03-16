//
//  ActivityPopoverViewController.swift
//  EGA
//
//  Created by Runa Alam on 27/04/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

protocol ActivityPopoverViewControllerDelegate {
    func didSelectActivity(_ activity: PFObject)
}

class ActivityPopoverViewController: UITableViewController,UISearchBarDelegate {

   
    var activities: [PFObject]! = []
    var delegate: ActivityPopoverViewControllerDelegate!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.delegate = self
        self.loadActivities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadActivities() {
        var query = PFQuery(className: PF_ACTIVITY_CLASS_NAME)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.activities.removeAll()
                self.activities.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    func searchActivity(_ searchActivity: String) {
        let activity = PFObject.self
        var query = PFQuery(className: PF_ACTIVITY_CLASS_NAME)
        query?.whereKey(PF_ACTIVITY_NAME, contains: searchActivity)
        query?.order(byAscending: PF_ACTIVITY_NAME)
        query.findObjectsInBackground { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.activities.removeAll(keepingCapacity: false)
                self.activities.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
            
        }
    }
    
    // MARK: - UISearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            self.searchActivity(searchText.lowercased())
        } else {
            self.loadActivities()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarCancelled()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelled() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        self.loadActivities()
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        
        let activity = self.activities[indexPath.row]
        cell.textLabel?.text = activity[PF_ACTIVITY_NAME] as? String
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.didSelectActivity(self.activities[indexPath.row])
            }
        })
    }
}
