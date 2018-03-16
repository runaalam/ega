//
//  GroupSelectViewController.swift
//  ega
//
//  Created by Runa Alam on 30/05/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

protocol GroupSelectViewControllerDelegate {
    func didSelectGroup(_ group: PFObject)
}

class GroupSelectViewController: UITableViewController, UISearchBarDelegate  {

    var groups: [PFObject]! = []
    var delegate: GroupSelectViewControllerDelegate!
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.loadGroups()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGroups() {
        var query = PFQuery(className: PF_GROUP_CLASS_NAME)
        query?.order(byAscending: PF_GROUP_NAME)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.groups.removeAll()
                self.groups.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    func searchGroups(_ searchGroup: String) {
        let group = PFObject.self
        var query = PFQuery(className: PF_GROUP_CLASS_NAME)
        query?.whereKey(PF_GROUP_NAME, contains: searchGroup)
        query?.order(byAscending: PF_GROUP_NAME)
        query.findObjectsInBackground { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.groups.removeAll(keepingCapacity: false)
                self.groups.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
    }
    
    // MARK: - UISearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            self.searchGroups(searchText.lowercased())
        } else {
            self.loadGroups()
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
        
        self.loadGroups()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        
        let group = self.groups[indexPath.row]
        cell.textLabel?.text = group[PF_GROUP_NAME] as? String
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.dismiss(animated: true, completion: { () -> Void in
              NSLog("------ did select pressed ------  \(self.delegate)")
            if self.delegate != nil {
                self.delegate.didSelectGroup(self.groups[indexPath.row])
            }
        })
    }
}
