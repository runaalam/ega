//
//  OtherPostViewController.swift
//  ega
//
//  Created by Runa Alam on 19/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class OtherPostListViewController: UITableViewController, UIActionSheetDelegate {
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadOtherPost(PUBLIC)
    }
    
    func loadOtherPost(_ privacy: Int) {
       /* posts = Post.loadOtherPostFromParse(privacy)
        tableView.reloadData()
        NSLog("---- POST COUNT ------ \(Post.loadOtherPostFromParse(privacy).count)")*/
        
        var query = PFQuery(className: PF_POST_CLASS_NAME)
        query?.whereKey(PF_POST_PRIVACY, equalTo: privacy)
        query?.whereKey(PF_POST_USER, notEqualTo: PFUser.current())
        query?.order(byDescending: PF_POST_DATE)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.posts.removeAll()
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var user = object[PF_POST_USER] as! PFUser
                        var innerQuery = PFQuery(className: PF_USER_CLASS_NAME)
                        innerQuery.whereKey(PF_USER_OBJECTID, equalTo: user.objectId)
                        user = innerQuery.getFirstObject() as! PFUser
                        var post = Post(post: object, user: user)
                        self.posts.append(post)
                        NSLog("---- POST Query ------ \(object)")
                    }
                    self.tableView.reloadData()
                }
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
   
    
    @IBAction func searchPostButtonPressed(_ sender: AnyObject) {
        
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:  "Network Post", "Group Posts", "Public Posts")
        actionSheet.show(from: (self.tabBarController?.tabBar)!)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch buttonIndex {
            
            case 1:
                    loadOtherPost(NETWORK)
            case 2:
                    loadOtherPost(GROUP)
            case 3:
                    loadOtherPost(PUBLIC)
            default:
                return
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("---- POSTS Count ------ \(self.posts.count)")

        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OtherPostCell
        let post = posts[indexPath.row]
        cell.usePost(post)
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let postVC = segue.destinationViewController.topViewController as? OtherPostDetailViewController {
            
            if "PostCell" == segue.identifier {
                if let path = tableView.indexPathForSelectedRow {
                    postVC.userPost = posts[path.row]
                }
            } 
        }
    }
}
