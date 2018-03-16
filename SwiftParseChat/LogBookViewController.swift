//
//  LogBookViewController.swift
//  EGA
//
//  Created by Runa Alam on 20/05/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

class LogBookViewController: UIViewController {

   
    @IBOutlet weak var userImageView: PFImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = PFUser.current() {
            self.loadUser()
        } else {
            Utilities.loginUser(self)
        }
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
    }
    
    func loadUser() {
        var user = PFUser.current()
        
        userImageView.file = user?[PF_USER_PICTURE] as? PFFile
        userImageView.load { (image: UIImage!, error: NSError!) -> Void in
            if error != nil {
                println(error)
            }
        }
        
        nameLabel.text = user?[PF_USER_FULLNAME] as? String
        
    }
/*
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if "DietDiary" == segue.identifier {
            let dietDiaryVC = segue.destinationViewController.topViewController as? DietDiaryViewController
            dietDiaryVC?.user = PFUser.currentUser()
        }
        
        
    }
    */

}
