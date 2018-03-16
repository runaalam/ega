//
//  OtherCommentViewController.swift
//  ega
//
//  Created by Runa Alam on 22/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    var userPost: Post = Post()
    var comments: [Comment] = []

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPostComments()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func loadPostComments() {
         
        var query = PFQuery(className: PF_COMMNET_CLASS_NAME)
        query?.whereKey(PF_COMMENT_POST, equalTo: userPost.post)
        query?.order(byAscending: PF_COMMENT_DATE)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
             NSLog("---- COMMENT Query ------ \(objects)")
            if error == nil {
                if let objects = objects as? [PFObject] {
                    self.comments.removeAll(keepingCapacity: true)
                    for object in objects {

                        var user = object[PF_COMMENT_USER] as! PFUser
                        var innerQuery = PFQuery(className: PF_USER_CLASS_NAME)
                        innerQuery.whereKey(PF_USER_OBJECTID, equalTo: user.objectId)
                        user = innerQuery.getFirstObject() as! PFUser
                        var comment = Comment(comment: object, user: user)
                        self.comments.append(comment)
                        
                    }
                    self.tableView.reloadData()
                }
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        if count(commentText.text) > 0 {
            var userComment = PFObject(className: PF_COMMNET_CLASS_NAME)
            
            userComment?[PF_COMMENT_USER] = PFUser.current()
            userComment?[PF_COMMENT_POST] = userPost.post
            userComment?[PF_COMMENT_TEXT] = commentText.text
            userComment?[PF_COMMENT_DATE] = Date()
            
            userComment.saveInBackground({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                   // ProgressHUD.showSuccess("Saved")
                    self.loadPostComments()
                    self.tableView.reloadData()
                    NSLog("------ Save data ------ . \(userComment)")
                } else {
                    NSLog("------ Error ------ . \(error)")
                    
                    ProgressHUD.showError("Network error")
                }
            })
        }
        commentText.text = ""
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("---- COMMENTS Count ------ \(self.comments.count)")
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.useComment(comment)
        
        return cell
    }
}
