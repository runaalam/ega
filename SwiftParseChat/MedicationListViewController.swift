//
//  MedicationListTableViewController.swift
//  ega
//
//  Created by Runa Alam on 2/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

/*protocol MedicationListViewControllerDelegate {
    func didSelectMedication(medication: PFObject)
}*/

class MedicationListViewController: UITableViewController {
    
    var user: PFUser = PFUser()
    var medications: [PFObject]! = []
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
   // var delegate: MedicationListViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMedications()
        
        if user != PFUser.current() {
            addButton.isEnabled = false
        }
        NSLog("************** User ************** \(user)")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadMedications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMedications() {
        var query = PFQuery(className: PF_MEDICATION_CLASS_NAME)
        query?.whereKey(PF_MEDICATION_USER, equalTo: user)
        query?.order(byAscending: PF_MEDICATION_NAME)
        query.findObjectsInBackground {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.medications.removeAll()
                self.medications.extend(objects as! [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }

    // MARK: - Table view data source

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        
        let medication = self.medications[indexPath.row]
        cell.textLabel?.text = medication[PF_MEDICATION_NAME] as? String
        
        return cell
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         NSLog("------ did select pressed ------  \(self.delegate)")
        if self.delegate != nil {
            self.delegate.didSelectMedication(self.medications[indexPath.row])
            NSLog("------ did select pressed ------  \(medications[indexPath.row])")

        }
    }*/
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let medicationVC = segue.destinationViewController.topViewController as? AddMedicationFormViewController {
            
            if "SelectedMedication" == segue.identifier {
                if let path = tableView.indexPathForSelectedRow {
                    medicationVC.userMedication = medications[path.row]
                    medicationVC.user = self.user
                }
            } else if "AddMedication" == segue.identifier {
                let medication = PFObject(className: PF_MEDICATION_CLASS_NAME)
                medicationVC.userMedication = medication
                medicationVC.user = self.user
            }
        }
    }
}
