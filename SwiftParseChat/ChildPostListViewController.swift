//
//  ChildPostListTableViewController.swift
//  ega
//
//  Created by Runa Alam on 7/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ChildPostListViewController: UITableViewController {

    var posts: [PFObject]! = []
    var childUser: PFUser = PFUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadChildPosts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadChildPosts()
    }
    
    func loadChildPosts() {
        NSLog("---- INSIDE POST---- \(childUser)")
        
        var query = PFQuery(className: PF_POST_CLASS_NAME)
        query?.whereKey(PF_POST_USER, equalTo: childUser)
        query?.whereKey(PF_POST_PRIVACY, notEqualTo: ONLY_ME)
        query?.order(byAscending: PF_POST_DATE)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                NSLog("---- POST count---- \(objects.count)")
                self.posts.removeAll()
                self.posts.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChildPostCell", for: indexPath) as! PostCell
        
        let post = self.posts[indexPath.row]
        cell.usePost(post)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let postVC = segue.destinationViewController.topViewController as? OtherPostDetailViewController {
            
            if "SelectedPost" == segue.identifier {
                if let path = tableView.indexPathForSelectedRow {
                    postVC.userPost = Post(post: self.posts[path.row] as PFObject)
                }
            } 
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
