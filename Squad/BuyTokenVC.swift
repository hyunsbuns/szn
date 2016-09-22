//
//  BuyTokenVC.swift
//  Squad
//
//  Created by Michael Litman on 8/16/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class BuyTokenVC: UIViewController
{
    @IBOutlet weak var qtyTF: UITextField!
    var teamWalletVC : TeamWalletVC!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buyButtonPressed()
    {
        let confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to purchase a token?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
            let obj = PFObject(className: "Wallet")
            obj["skwad"] = SquadCore.selectedSquad
            obj["player"] = SquadCore.currentPlayer
            obj["type"] = "credit"
            obj["amount"] = Int(self.qtyTF.text!)
            obj.saveInBackground { (success: Bool, error: Error?) in
                if(!success)
                {
                    let alert = UIAlertController(title: "Error", message: "There was a problem with the purchase, please try again shortly.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: "Success", message: "The purchase was complete and the tokens have been added to your Skwad's wallet.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        self.teamWalletVC.getCurrentActivity()
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        confirmAlert.addAction(yesAction)
        confirmAlert.addAction(cancelAction)
        self.present(confirmAlert, animated: true, completion: nil)
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
