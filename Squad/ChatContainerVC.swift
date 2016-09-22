//
//  ChatContainerVC.swift
//  Squad
//
//  Created by Michael Litman on 8/11/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

//This guy only holds the embed and checks for premium

class ChatContainerVC: UIViewController
{
    var premiumRequiredVC : PremiumRequiredVC!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.premiumRequiredVC = self.storyboard?.instantiateViewController(withIdentifier: "PremiumRequiredVC") as! PremiumRequiredVC
        self.premiumRequiredVC.navBarTitleText = "Chat"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if(!SquadCore.premiumEnabled)
        {
            self.view.addSubview(self.premiumRequiredVC.view)
        }
        else
        {
            self.premiumRequiredVC.view.removeFromSuperview()
        }
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
