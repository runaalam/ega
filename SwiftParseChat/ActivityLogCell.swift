//
//  ActivityLogCell.swift
//  ega
//
//  Created by Runa Alam on 19/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ActivityLogCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var caloriBurnLabel: UILabel!
    
    func useActivity(_ activity: Activity){
        
        dateLabel.text = Utilities.stringDateFormate(activity.date as Date)
        activityNameLabel.text = activity.activityName
        durationLabel.text = Utilities.getHrMinString(activity.duration!)
        caloriBurnLabel.text = toString(activity.caloriBurn!)
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
