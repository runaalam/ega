/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Application-specific color convenience methods.
            
*/

import UIKit

extension UIColor {
    class func applicationGreenColor() -> UIColor {
        return UIColor(red: 0.255, green: 0.804, blue: 0.470, alpha: 1)
    }

    class func applicationBlueColor() -> UIColor {
        return UIColor(red: 0.333, green: 0.784, blue: 1, alpha: 1)
    }

    class func applicationPurpleColor() -> UIColor {
        return UIColor(red: 0.659, green: 0.271, blue: 0.988, alpha: 1)
    }
}

extension UIImage {
    func imageWithColor(_ tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(kCGBlendModeNormal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

