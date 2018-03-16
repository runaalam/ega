//
//  ChildViewController.swift
//  ega
//
//  Created by Runa Alam on 2/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ChildViewController: UITableViewController {
    
    var childUser: PFUser = PFUser()
    var row = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
      // self.loadChild()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadChild()
    }
    
    func loadChild() {
        
        var query = PFQuery(className: PF_NETWORK_CLASS_NAME)
        query?.whereKey(PF_NETWORK_USER, equalTo: PFUser.current())
        query?.includeKey(PF_NETWORK_USER_CHILD)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil || object != nil {
                self.childUser = object![PF_NETWORK_USER_CHILD] as! PFUser
                self.row = 5
                self.tableView.reloadData()
                NSLog("---- Inside CVC --------- \(self.childUser) ---- ")
            } else {
                self.row = 0
                self.tableView.reloadData()
                self.showConnectionAlert()
                NSLog("------ Error ------ . \(error)")
                ProgressHUD.showError("Network error")
            }
        }
    }

    // MARK: - Table view data source
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row
        
    }
    
    func showConnectionAlert() {
        let title = NSLocalizedString("Sorry", comment: "")
        let message = NSLocalizedString("No child assign yet", comment: "")
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The simple alert's cancel action occured.")
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
       // dismissViewControllerAnimated(true, completion: nil)
        present(alertController, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
          NSLog("---------INSIDE SEGUE-------------")
        if childUser.objectId != nil {
            if let childPostVC = segue.destinationViewController.topViewController as? ChildPostListViewController {
                if "ChildPosts" == segue.identifier {
                    childPostVC.childUser = self.childUser
                }
            }
            if let childProfileVC = segue.destinationViewController.topViewController as? ChildProfileViewController {
                if "ChildProfile" == segue.identifier {
                    childProfileVC.childUser = self.childUser
                }
            }
            if let childActivityVC = segue.destinationViewController.topViewController as? ActivityLogViewController {
                if "ChildActivityLog" == segue.identifier {
                    childActivityVC.user = self.childUser
                }
            }
            if let childMedicationVC = segue.destinationViewController.topViewController as? MedicationLogViewController {
                if "ChildMedicationLog" == segue.identifier {
                    childMedicationVC.user = self.childUser
                }
            }
            if let childDietDiaryVC = segue.destinationViewController.topViewController as? DietDiaryViewController {
                if "ChildDietDiary" == segue.identifier {
                    childDietDiaryVC.user = self.childUser
                }
            }
        }
    }
}
