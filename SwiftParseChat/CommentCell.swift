//
//  CommentCell.swift
//  ega
//
//  Created by Runa Alam on 21/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userImage: PFImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var coammentDetailslabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func useComment(_ comment:Comment) {
        
        userNameLabel.text = comment.userName
        coammentDetailslabel.text = comment.description
        dateLabel.text = comment.date
    
        userImage.file = comment.userImage
        userImage.load { (image: UIImage!, error: NSError!) -> Void in
            if error != nil {
                println(error)
            }
        }
        userImage.layer.cornerRadius = userImage.frame.size.width / 2;
        userImage.layer.masksToBounds = true;
    
    }
    
}
