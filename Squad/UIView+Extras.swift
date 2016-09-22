//
//  UIView+Extras.swift
//  Squad
//
//  Created by Michael Litman on 4/30/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

extension UIView
{
    @IBAction func clearText(_ sender: UITextInput)
    {
        sender.replace(sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)!, withText: "")
    }
    
    @IBAction func resignFirstResponder(_ sender: AnyObject)
    {
        sender.resignFirstResponder()
    }
    
    func maskAsCircle()
    {
        let v = self
        v.layer.cornerRadius = max(self.getWidth(), self.getHeight())/2
        v.layer.borderWidth = 0.0
        v.layer.borderColor = UIColor.clear.cgColor
        v.layer.masksToBounds = true
        v.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func maskWithBorder(_ width: CGFloat, color: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func maskWithUnderline()
    {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.getHeight() - width, width: self.getWidth(), height: self.getHeight())
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func getHeight() -> CGFloat
    {
        return self.frame.size.height
    }
    
    func getWidth() -> CGFloat
    {
        return self.frame.size.width
    }
    
    func setPosition(_ x : CGFloat, y : CGFloat)
    {
        let f = self.frame
        self.frame = CGRect(x: x, y: y, width: f.size.width, height: f.size.height)
    }
    
    func setHeight(_ height : CGFloat)
    {
        let f = self.frame
        self.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.size.width, height: height)
    }
    
    func setWidth(_ width : CGFloat)
    {
        let f = self.frame
        self.frame = CGRect(x: f.origin.x, y: f.origin.y, width: width, height: f.size.height)
    }
    
    func setRect(_ x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat)
    {
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }
}

