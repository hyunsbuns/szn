//
//  PremiumRequiredVC.swift
//  Squad
//
//  Created by Michael Litman on 8/11/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class PremiumRequiredVC: UIViewController
{
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backButton: UIButton!
    var showBackButton = false
    var navBarTitleText = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.backButton.isHidden = !self.showBackButton
        self.navBar.topItem?.title = self.navBarTitleText
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
