//
//  TabViewController.swift
//  EGA
//
//  Created by Runa Alam on 19/05/2015.
//  Copyright (c) 2015 RunaAlam. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove edit button from more tab
        self.customizableViewControllers = nil
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

