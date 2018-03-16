//
//  OtherPostDetailViewController.swift
//  ega
//
//  Created by Runa Alam on 21/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class OtherPostDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate  {
    
    var userPost: Post = Post()

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
       loadPostDetail()
    }
    
    func loadPostDetail() {
        userNameLabel.text = userPost.userName
        titleLabel.text = userPost.title
        dateLabel.text = userPost.date
        privacyLabel.text = userPost.privacy
        descriptionLabel.text = userPost.description
    }

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func commentButtonPressed(_ sender: AnyObject) {
        
        NSLog("------------POST ID---------------- \(userPost)")

        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "CommentPop") as! CommentViewController
        popoverVC.userPost = self.userPost
        popoverVC.modalPresentationStyle = .popover
        
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
    }   
}
