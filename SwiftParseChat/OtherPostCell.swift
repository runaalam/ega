//
//  OtherPostCell.swift
//  ega
//
//  Created by Runa Alam on 20/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class OtherPostCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var userImage: PFImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postDetailsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    func usePost(_ post:Post) {
       // view.layer.cornerRadius = 10;
      //  view.layer.masksToBounds = true;
        // Fill in the data
        userNameLabel.text = post.userName
        postDateLabel.text = post.date
        postTitleLabel.text = post.title
        postDetailsLabel.text = post.description
        privacyLabel.text = post.privacy
        
        userImage.file = post.userImage
        userImage.load { (image: UIImage!, error: NSError!) -> Void in
                if error != nil {
                    println(error)
                }
        }
        userImage.layer.cornerRadius = userImage.frame.size.width / 2;
        userImage.layer.masksToBounds = true;
   
    }
}
