//
//  Post.swift
//  ega
//
//  Created by Runa Alam on 20/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Post {
    
    var userID: String?
    var userImage: PFFile?
    var userName: String?
    var postID: String!
    var title: String?
    var date: String?
    var privacy: String?
    var description: String?
    var post: PFObject?
    
    init() {}
    
    init(post: PFObject, user: PFUser) {
        
        userID       = user.objectId                          as String
        userName     = user[PF_USER_FULLNAME]                 as? String
        userImage    = user[PF_USER_PICTURE]                  as? PFFile
        
        postID       = post.objectId                          as String
        title        = post[PF_POST_TITLE]                    as? String
        description  = post[PF_POST_DESCRITION]               as? String
        
        date         = Utilities.stringDateFormate(post[PF_POST_DATE] as! Date)
        privacy      = Utilities.getPrivacyString(post[PF_POST_PRIVACY] as! Int)
        self.post    = post                                   as PFObject
       
        
        /* var user = post[PF_POST_USER] as! PFUser
        
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, equalTo: user.objectId)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil || object != nil {
                user = object as! PFUser
                NSLog("\n------------UER \(user)")
                self.userName     = user[PF_USER_FULLNAME] as? String
                self.userImage    = user[PF_USER_PICTURE] as? PFFile
                NSLog("\n---- INSIDE INIT \(self.userName)")
                println("Successfully retrieved the object.")
            } else {
                println("The getFirstObject request failed.")
            }
        }*/
        
        NSLog("\n---- INSIDE INIT \(postID)")
    }
    
    init(post: PFObject) {
        
        postID       = post.objectId                          as String
        title        = post[PF_POST_TITLE]                    as? String
        description  = post[PF_POST_DESCRITION]               as? String
        
        date         = Utilities.stringDateFormate(post[PF_POST_DATE] as! Date)
        privacy      = Utilities.getPrivacyString(post[PF_POST_PRIVACY] as! Int)
        self.post    = post 
    }
    
   
    
   /* class func loadOtherPostFromParse(privacy: Int) -> [Post]
    {
        var posts:[Post] = []
        
        var query = PFQuery(className: PF_POST_CLASS_NAME)
        query.whereKey(PF_POST_PRIVACY, equalTo: privacy)
        query.orderByAscending(PF_POST_DATE)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var post = Post(post: object)
                        posts.append(post)
                    }
                    
                }
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
        NSLog("---- POST COUNT ------ \(posts.count)")
        return posts
    }*/
}

