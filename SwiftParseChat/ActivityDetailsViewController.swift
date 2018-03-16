//
//  ActivityDetailsViewController.swift
//  EGA
//
//  Created by Runa Alam on 22/04/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

class ActivityDetailsViewController: UITableViewController, PopUpPickerViewDelegate, UIPickerViewAccessibilityDelegate, UIPopoverPresentationControllerDelegate {

   
    @IBOutlet weak var activityDetailNavigation: UINavigationItem!
    
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var noteText: UITextView!
    
    @IBOutlet weak var durationBtn: UIButton!
    
    var pickerView: PopUpPickerView!
    
    let array = ["5", "10", "15", "20", "25", "30", "35", "40", "45",
                    "50", "55", "60", "65", "70", "75", "80", "85", "90",
                    "95", "100","105", "110", "115", "120"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        updateDateLabel(Date())
       
        configPickerView()
        
               //for UITextView border
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        noteText.layer.borderWidth = 0.5
        noteText.layer.borderColor = borderColor.cgColor
        noteText.layer.cornerRadius = 5.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK Configuration
    
    func configPickerView() {
    
        pickerView = PopUpPickerView()
        pickerView.delegate = self
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(pickerView)
        } else {
            self.view.addSubview(pickerView)
        }
    }
    
    func configureNavigationBar() {
    
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ActivityDetailsViewController.doneBarButtonItemClicked))
    
        activityDetailNavigation.setRightBarButton(doneBarButtonItem, animated: true)
    
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ActivityDetailsViewController.cancelBarButtonItemClicked))
    
        activityDetailNavigation.setLeftBarButton(cancelBarButtonItem, animated: true)
    
    }
    
    func doneBarButtonItemClicked() {
        // Dismiss the keyboard by removing it as the first responder.
        
        navigationItem.setRightBarButton(nil, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelBarButtonItemClicked() {
        // Dismiss the keyboard by removing it as the first responder.
        
        navigationItem.setLeftBarButton(nil, animated: true)
        
        showCancelActionSheet()
    }
    
    func showCancelActionSheet() {
        
        //  let title = NSLocalizedString("A Short Title is Best", comment: "")
        let message = NSLocalizedString("Are you sure you want to cancel what you have done?", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let otherButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            self.dismiss(animated: true, completion: nil)
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        present(alertCotroller, animated: true, completion: nil)
    }
    
    @IBAction func dateButtonClicked(_ sender: AnyObject) {
        DatePickerDialog().show(doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: "Date and Time", datePickerMode: .DateAndTime) {
            (date) -> Void in
            
            self.updateDateLabel(date)
        }
    }
    
    
    @IBAction func ActivityBtnClicked(_ sender: AnyObject) {
        
        /*let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("ActivityPopOver") as! UIViewController
        popoverVC.modalPresentationStyle = .Popover
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)*/
    }
     @IBAction func durationBtnClicked(_ sender: AnyObject) {
        
        durationBtn.addTarget(self, action: #selector(ActivityDetailsViewController.showPicker), for: UIControlEvents.touchDown)
      
    }
    
    func updateDateLabel(_ date: Date) {
        
        //let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: date)
        activityDateLabel.text = "\(dateString)"
    }
    
   /* func didSelectActivity(activity: PFObject){
        
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 5
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func showPicker() {
        pickerView.showPicker()
    }
    // for delegate
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return array[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        durationLabel.text = array[row] + " min"
        
    }

}
