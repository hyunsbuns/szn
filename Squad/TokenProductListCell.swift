//
//  TokenProductListCell.swift
//  Squad
//
//  Created by Michael Litman on 8/17/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import SwiftInAppPurchase
import Parse

class TokenProductListCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    var productID : String!
    var qty : Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func buyButtonPressed()
    {
        let iap = SwiftInAppPurchase.sharedInstance
        iap.addPayment(self.productID, userIdentifier: nil) { (result) -> () in
            
            switch result{
            case .purchased( _,let transaction,let paymentQueue):
                //print("Purchase Success \(productId)")
                //record the purchase in Parse
                let obj = PFObject(className: "Wallet")
                obj["skwad"] = SquadCore.selectedSquad
                obj["player"] = SquadCore.currentPlayer
                obj["type"] = "credit"
                obj["amount"] = self.qty
                obj.saveInBackground()
                paymentQueue.finishTransaction(transaction)
            case .failed( _): break
                //print(error)
            default:
                break
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
