//
//  LoginViewController.swift
//  SwiftParseChat
//
//  Created by Runa Alam on 19/05/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
   
    // @IBOutlet var emailField: UITextField!
   // @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard)))
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emailField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        } else if textField == self.passwordField {
            self.login()
        }
        return true
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        self.login();
    }
    
    /*@IBAction func loginButtonPressed(sender: UIButton) {
        self.login();
    }*/
    
    func login() {
        let email = emailField.text?.lowercased()
        let password = passwordField.text
        
        if count(email) == 0 {
            ProgressHUD.showError("Email field is empty.")
            return
        } else {
            ProgressHUD.showError("Password field is empty.")
        }
        
        ProgressHUD.show("Signing in...", interaction: true)
        PFUser.logInWithUsernameInBackground(email, password: password) { (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                PushNotication.parsePushUserAssign()
                ProgressHUD.showSuccess("Welcome back, \(user[PF_USER_FULLNAME])!")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                if let info = error.userInfo {
                    ProgressHUD.showError(info["error"] as! String)
                }
            }
        }
    }
    
    
    @IBAction func facebookLogin(_ sender: AnyObject) {
        
        ProgressHUD.show("Signing in...", interaction: false)
        PFFacebookUtils.logIn(withPermissions: ["public_profile", "email", "user_friends"], block: { (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                if user[PF_USER_FACEBOOKID] == nil {
                    self.requestFacebook(user)
                } else {
                    self.userLoggedIn(user)
                }
            } else {
                if error != nil {
                    println(error)
                    if let info = error.userInfo {
                        println(info)
                    }
                }
                ProgressHUD.showError("Facebook sign in error")
            }
        })
    }
    
    func requestFacebook(_ user: PFUser) {
        var request = FBRequest.forMe()
        request?.start { (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                var userData = result as! [String: AnyObject]!
                self.processFacebook(user, userData: userData)
            } else {
                PFUser.logOut()
                ProgressHUD.showError("Failed to fetch Facebook user data")
            }
        }
    }
    
    func processFacebook(_ user: PFUser, userData: [String: AnyObject]) {
        let facebookUserId = userData["id"] as! String
        var link = "http://graph.facebook.com/\(facebookUserId)/picture"
        let url = URL(string: link)
        var request = URLRequest(url: url!)
        let params = ["height": "200", "width": "200", "type": "square"]
        Alamofire.request(.GET, link, parameters: params).response() {
            (request, response, data, error) in
            
            if error == nil {
                var image = UIImage(data: data! as! NSData)!
                
                if image.size.width > 280 {
                    image = Images.resizeImage(image, width: 280, height: 280)!
                }
                var filePicture = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6))
                filePicture.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                    if error != nil {
                        ProgressHUD.showError("Error saving photo")
                    }
                })
                
                if image.size.width > 60 {
                    image = Images.resizeImage(image, width: 60, height: 60)!
                }
                var fileThumbnail = PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(image, 0.6))
                fileThumbnail.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                    if error != nil {
                        ProgressHUD.showError("Error saving thumbnail")
                    }
                })
                
                user[PF_USER_EMAILCOPY] = userData["email"]
                user[PF_USER_FULLNAME] = userData["name"]
                user[PF_USER_FULLNAME_LOWER] = (userData["name"] as! String).lowercaseString
                user[PF_USER_FACEBOOKID] = userData["id"]
                user[PF_USER_PICTURE] = filePicture
                user[PF_USER_THUMBNAIL] = fileThumbnail
                user.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    if error == nil {
                        self.userLoggedIn(user)
                    } else {
                        PFUser.logOut()
                        if let info = error!.userInfo {
                            ProgressHUD.showError("Login error")
                            println(info["error"] as! String)
                        }
                    }
                })
            } else {
                PFUser.logOut()
                if let info = error!.userInfo {
                    ProgressHUD.showError("Failed to fetch Facebook photo")
                    println(info["error"] as! String)
                }
            }
        }
    }
    
    func userLoggedIn(_ user: PFUser) {
        PushNotication.parsePushUserAssign()
        ProgressHUD.showSuccess("Welcome back, \(user[PF_USER_FULLNAME])!")
        self.dismiss(animated: true, completion: nil)
    }

}
