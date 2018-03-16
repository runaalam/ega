//
//  PostCell.swift
//  ega
//
//  Created by Runa Alam on 22/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postDetailsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    func usePost(_ post: PFObject) {
        
        postTitleLabel.text = post[PF_POST_TITLE] as? String
        postDetailsLabel.text = post[PF_POST_DESCRITION] as? String
        postDateLabel.text  = Utilities.stringDateFormate(post[PF_POST_DATE] as! Date)
        privacyLabel.text = Utilities.getPrivacyString(post[PF_POST_PRIVACY] as! Int)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
