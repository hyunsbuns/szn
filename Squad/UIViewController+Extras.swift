//
//  UIViewController+Extras.swift
//  Squad
//
//  Created by Michael Litman on 4/30/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

extension UIViewController
{
    @IBAction func standardActionCancelButtonPressed(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func standardActionCancelButtonPressedNotAnimated(_ sender: AnyObject)
    {
        self.dismiss(animated: false, completion: nil)
    }    
}

