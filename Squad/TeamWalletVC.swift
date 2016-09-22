//
//  TeamWalletVC.swift
//  Squad
//
//  Created by Michael Litman on 8/14/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class TeamWalletVC: UIViewController
{
    @IBOutlet weak var currentTokenCountLabel: UILabel!
    @IBOutlet weak var addPremiumTimeButton: UIButton!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var hoursLeftLabel: UILabel!
    @IBOutlet weak var minutesLeftLabel: UILabel!
    var activityList : WalletActivityList!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.addPremiumTimeButton.isHidden = true
        let owner = SquadCore.selectedSquad["owner_id"] as! PFUser
        if(SquadCore.currentUser.objectId! == owner.objectId!)
        {
           self.addPremiumTimeButton.isHidden = false
        }
        
        if(SquadCore.selectedSquad["credits"] != nil)
        {
            let credits = SquadCore.selectedSquad["credits"] as! NSNumber
            self.currentTokenCountLabel.text = "Credits \(credits)"
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if(SquadCore.selectedSquad["premium_expiration"] != nil)
        {
            let expires = SquadCore.selectedSquad["premium_expiration"] as! Date
            let minsLeft = SquadCore.premiumMinutesLeft(expires)
            let daysString = SquadCore.premiumMinutesToTimeLeftString(minsLeft)
            let parts = daysString.components(separatedBy: ":")
            self.daysLeftLabel.text = parts[0]
            self.hoursLeftLabel.text = parts[1]
            self.minutesLeftLabel.text = parts[2]
        }
        self.getCurrentActivity()
    }
    
    func getCurrentActivity()
    {
        let query = PFQuery(className: "Wallet")
        query.whereKey("skwad", equalTo: SquadCore.selectedSquad)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if(error == nil)
            {
                //get the current number of credits
                var credits = 0
                for obj in objects!
                {
                    let type = obj["type"] as! String
                    if(type == "credit")
                    {
                        credits += obj["amount"] as! Int
                    }
                    else
                    {
                        credits -= obj["amount"] as! Int
                    }
                }
                self.currentTokenCountLabel.text = "Credits \(credits)"
                SquadCore.currentSkwadCredits = credits
                self.activityList.data.removeAll()
                self.activityList.data.append(contentsOf: objects!)
                self.activityList.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier != nil)
        {
            if(segue.identifier! == "WalletActivityList")
            {
                self.activityList = segue.destination as! WalletActivityList
            }
            else if(segue.identifier! == "BuyTokenVC")
            {
                let dest = segue.destination as! BuyTokenVC
                dest.teamWalletVC = self
            }
        }
    }
    

}
