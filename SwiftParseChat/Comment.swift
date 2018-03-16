//
//  Comment.swift
//  ega
//
//  Created by Runa Alam on 21/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Comment {
    
    var userID: String?
    var userImage: PFFile?
    var userName: String?
    var date: String?
    var description: String?
    
    init() {}
    
    init(comment: PFObject, user: PFUser) {
        
        userID       = user.objectId as String
        userName     = user[PF_USER_FULLNAME] as? String
        userImage    = user[PF_USER_PICTURE]  as? PFFile
        
        description  = comment[PF_COMMENT_TEXT] as? String
        
        date         = Utilities.stringDateFormate(comment[PF_COMMENT_DATE] as! Date)
        
    }
}
