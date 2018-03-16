//
//  DiaryListViewController.swift
//  EGA
//
//  Created by Runa Alam on 19/04/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

class PostListViewController: UITableViewController {

   // @IBOutlet weak var emptyPost: UIView!
    
    var posts: [PFObject]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(PostListViewController.loadPosts), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(self.refreshControl!)
        
      //  self.emptyPost?.hidden = true
       // self.loadPosts()
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPosts() {
        var query = PFQuery(className: PF_POST_CLASS_NAME)
        query?.whereKey(PF_POST_USER, equalTo: PFUser.current())
        query?.order(byDescending: PF_POST_DATE)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.posts.removeAll()
                self.posts.extend(objects as! [PFObject]!)
               // self.updateEmptyPost()
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    func updateEmptyPost() {
       // self.emptyPost?.hidden = (self.posts.count != 0)
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
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        let post = self.posts[indexPath.row]
         cell.usePost(post)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let postVC = segue.destinationViewController.topViewController as? PostDetailViewController {
            
            if "SelectedPost" == segue.identifier {
                if let path = tableView.indexPathForSelectedRow {
                    postVC.userPost = posts[path.row]
                }
            } else if "NewPost" == segue.identifier {
                let post = PFObject(className: PF_POST_CLASS_NAME)
                postVC.userPost = post
            }
        }
    }
}
