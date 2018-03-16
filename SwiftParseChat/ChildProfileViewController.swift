//
//  ChildProfileViewController.swift
//  ega
//
//  Created by Runa Alam on 9/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ChildProfileViewController: UITableViewController {

    var childUser: PFUser = PFUser()
    
    @IBOutlet weak var userImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadChildInfo()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadChildInfo()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
    }

    
    func loadChildInfo() {
        
        userImageView.file = childUser[PF_USER_PICTURE] as? PFFile
        userImageView.load { (image: UIImage!, error: NSError!) -> Void in
            if error != nil {
                println(error)
            }
        }
        
        if childUser[PF_USER_FULLNAME] != nil {
            nameLabel.text = "\(childUser[PF_USER_USERNAME])"
        }
        
        if childUser[PF_USER_EMAILCOPY] != nil {
            emailLabel.text = "\(childUser[PF_USER_EMAILCOPY])"
        }
        
        if childUser[PF_USER_GENDER] != nil {
            genderLabel.text = "\(childUser[PF_USER_GENDER])"
        }
        
        if childUser[PF_USER_DOB] != nil {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            let dateString = formatter.string(for: childUser[PF_USER_DOB])!
            dobLabel.text = "\(dateString)"
        }
        
        if childUser[PF_USER_HEIGHT] != nil {
            heightLabel.text = "\(childUser[PF_USER_HEIGHT]) (cm)"
        }
        if childUser[PF_USER_WEIGHT] != nil {
            weightLabel.text = "\(childUser[PF_USER_WEIGHT]) (kg)"
        }
        
        if childUser[PF_USER_GROUP] != nil {
            var query = PFQuery(className: PF_GROUP_CLASS_NAME)
            query?.whereKey(PF_GROUP_OBJECTID, equalTo: (childUser[PF_USER_GROUP] as AnyObject).objectId)
            query.findObjectsInBackground {
                (objects: [AnyObject]?, error: NSError?) -> Void in
            
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            self.groupNameLabel.text = "\(object[PF_GROUP_NAME])"
                        }
                    }
                
                } else {
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        } else {
            self.groupNameLabel.text = ""
        }
       /* if childUser[PF_USER_GROUP] != nil {
            groupNameLabel.text = "\(childUser[PF_USER_GROUP].objectId)"
        }*/
    }

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 7
    }

  
}
