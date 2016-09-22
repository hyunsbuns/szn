//
//  PremiumPurchaseListCell.swift
//  Squad
//
//  Created by Michael Litman on 8/20/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import SwiftDate
import Parse

class PremiumPurchaseListCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    var numDays : Int!
    var cost : Int!
    var premiumList : PremiumPurchaseList!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func buyButtonPressed()
    {
        if(cost > SquadCore.currentSkwadCredits)
        {
            let alert = UIAlertController(title: "Error", message: "You do not have enough tokens.  Please buy more tokens to proceed.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            })
            alert.addAction(okAction)
            self.premiumList.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to purchase \(self.numDays) days or premium time for \(cost) tokens?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
                let expires = SquadCore.selectedSquad["premium_expiration"] as! Date
                let minsLeft = SquadCore.premiumMinutesLeft(expires)
                var newExpires : Date!
                if(minsLeft == 0)
                {
                    newExpires = self.numDays.days.fromNow
                }
                else
                {
                    newExpires = self.numDays.days.fromDate(expires)
                }
                
                SquadCore.selectedSquad["premium_expiration"] = newExpires
                SquadCore.selectedSquad.saveInBackground(block: { (success: Bool, error: Error?) in
                    if(success)
                    {
                        let obj = PFObject(className: "Wallet")
                        obj["skwad"] = SquadCore.selectedSquad
                        obj["player"] = SquadCore.currentPlayer
                        obj["type"] = "debit"
                        obj["amount"] = self.cost
                        obj.saveInBackground(block: { (success: Bool, error: Error?) in
                            
                            if(success)
                            {
                                let alert = UIAlertController(title: "Success", message: "You have added \(self.numDays) days of premium time to your Skwad!", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                    self.premiumList.dismiss(animated: true, completion: nil)
                                })
                                alert.addAction(okAction)
                                self.premiumList.present(alert, animated: true, completion: nil)
                            }
                            else
                            {
                                let alert = UIAlertController(title: "Error", message: "There was a problem adding premium time to your Skwad, please try again shortly.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                    
                                })
                                alert.addAction(okAction)
                                self.premiumList.present(alert, animated: true, completion: nil)
                            }
                        })
                    }
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(cancelAction)
            self.premiumList.present(alert, animated: true, completion: nil)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
