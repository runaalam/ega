//
//  EgaViewTests.swift
//  ega
//
//  Created by Runa Alam on 26/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import XCTest

class EgaViewTests: XCTestCase {
    
    
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
        
    }
    
    func testViewControllerLoad() {
        
        let vc = ViewController()
        XCTAssertNotNil(vc.view, "View should load for ViewController")
        
    }
    
}