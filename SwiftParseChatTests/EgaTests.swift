//
//  EgaTests.swift
//  ega
//
//  Created by Runa Alam on 26/06/2015.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import XCTest


class EgaTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
        
    }
    
    
    func calculateCalorieBurn(_ age: Float, height: Float, weight:
        Float, gender: String, metValue: Float, duration: Int) -> Float {
            
            var BMR = Float()
            
            if (age == 0.0) || (height == 0.0) || (weight == 0.0) {
                return 0.0
            }
        
            if (metValue == 0.0) || (duration == 0) {
                return 0.0
            }
            
            if gender.isEqual("Male") {
                BMR = 0.0
                BMR += (13.75 * weight)
                BMR += (5 * height)
                BMR -= (6.76 * age)
                BMR += 66
            } else {
                BMR = 0.0
                BMR += (9.56 * weight)
                BMR += (18.5 * height)
                BMR -= (4.68 * age)
                BMR += 655
            }
            
            let calorieBurn = ((BMR / 24.00) * metValue  * Float(duration))
            
            return calorieBurn
            
    }
    
    
    
    func testMaleCalorieCalculation() {
        
        let cal = calculateCalorieBurn(30, height: 150 , weight: 70
            ,gender: "Male", metValue: 5.5, duration: 60)
        
        let intCal = Int(cal)
        
        NSLog("cal: %f, intCal: %d", cal, intCal)
        
        XCTAssertTrue(21665 == intCal, "testMaleCalorieCalculation calorie counnt should be according to the formula")
        
    }
    
    
    
    
    
    func testFemaleCalorieCalculation() {
        
        let cal = calculateCalorieBurn(30, height: 150 , weight: 70
            ,gender: "Female", metValue: 5.5, duration: 60)
        
        let intCal = Int(cal)
        
        NSLog("cal: %f, intCal: %d", cal, intCal)
        
        XCTAssertTrue(54433 == intCal, "testFemaleCalorieCalculation calorie counnt should be according to the formula")
    }
    
    
    
    func testErrorCalorieCalculation() {
        
        let cal = calculateCalorieBurn(30, height: 0 , weight: 70
            ,gender: "Male", metValue: 5.5, duration: 60)
        
        let intCal = Int(cal)
        
        NSLog("cal: %f, intCal: %d", cal, intCal)
        
        XCTAssertTrue(0 == intCal, "testErrorCalorieCalculation For any 0 paramter the result should be 0")
    }
    
}
