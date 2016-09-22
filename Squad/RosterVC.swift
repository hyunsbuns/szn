//
//  RosterVC.swift
//  Squad
//
//  Created by Michael Litman on 12/8/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import ContactsUI

class RosterVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactPickerDelegate
{
    var statCache = [String : [StatTotals]]()
    @IBOutlet weak var addDummyButton: UIBarButtonItem!
    @IBOutlet weak var invitePlayersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var premiumRequiredVC : PremiumRequiredVC!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.premiumRequiredVC = self.storyboard?.instantiateViewController(withIdentifier: "PremiumRequiredVC") as! PremiumRequiredVC
        self.premiumRequiredVC.navBarTitleText = "Profile"
        self.premiumRequiredVC.showBackButton = true
        
        if(SquadCore.isAdmin(SquadCore.selectedSquad, user: SquadCore.currentUser))
        {
            self.invitePlayersButton.isHidden = false
            self.addDummyButton.isEnabled = true
        }
        else
        {
            self.invitePlayersButton.isHidden = true
            self.addDummyButton.isEnabled = false

        }
        //get the PFUsers associated with this Squad

        
        self.view.backgroundColor = asphaltColor
        
        /*
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [skwadDarkGrey.CGColor, UIColor.blackColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        */
        
    }
    

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty)
    {
        if(contactProperty.key == "phoneNumbers")
        {
            let phoneNumber = contactProperty.value as! CNPhoneNumber
            let obj = PFObject(className: "Invites")
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            obj.acl = acl
            obj["squadID"] = SquadCore.selectedSquad
            obj.saveInBackground(block: { (success: Bool, error: Error?) in
                let appURL = "www.awesomefat.com"
                let msg = "You've been invited to join the \(SquadCore.selectedSquad["name"] as! String) on the SZN app: \(appURL), Copy and paste the following code to join: \(obj.objectId!)"
                SquadCore.sendSMS(msg, to: phoneNumber.stringValue)
            })
        }
    }
    
    @IBAction func invitePlayerButtonPressed(_ sender: UIButton)
    {
        let vc = CNContactPickerViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        if(SquadCore.profile_ReloadStats)
        {
            self.statCache.removeAll()
            SquadCore.profile_ReloadStats = false
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return SquadCore.selectedSquadRoster.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RosterTableViewCell

        // Configure the cell...
        let player = SquadCore.selectedSquadRoster[(indexPath as NSIndexPath).row]
        let user = player["user"]
        var name = ""
        if(user == nil)
        {
            let fname = player["firstName"] as! String
            let lname = player["lastName"] as! String
            name = "\(fname) \(lname)"
            let imageName = player["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: cell.profileImage, imageName: imageName as! String, profileImage: true)
            }
            cell.nameLabel.text = name
        }
        else
        {
            (user as! PFUser).fetchIfNeededInBackground(block: { (obj: PFObject?, error: Error?) in
                name = "\((user as! PFUser)["firstName"] as! String) \((user as! PFUser)["lastName"] as! String)"
                let imageName = (user as! PFUser)["imageName"]
                if(imageName != nil)
                {
                    SquadCore.getImage(iv: cell.profileImage, imageName: imageName as! String, profileImage: true)
                }
                cell.nameLabel.text = name
            })
            
        }
        //cell.nameLabel.text = name.uppercaseString
        
        let number = player["jersey_number"]
        if(number != nil)
        {
            cell.jerseyNumberLabel.text = number as? String
        }
        else
        {
            cell.jerseyNumberLabel.text = ""
        }
        /*
        let position1 = player["position1"] as? PFObject
        var pos1String = ""
        if(position1 != nil)
        {
            try! position1?.fetchIfNeeded()
            pos1String = position1!["position"] as! String
        }
        let position2 = player["position2"] as? PFObject
        var pos2String = ""
        if(position2 != nil)
        {
            try! position2?.fetchIfNeeded()
            pos2String = position2!["position"] as! String
        }
        var posString = ""
        if(pos1String != "" && pos2String != "")
        {
            posString = "\(pos1String) / \(pos2String)"
        }
        else if(pos1String != "")
        {
            posString = "\(pos1String)"
        }
        else if(pos2String != "")
        {
            posString = "\(pos2String)"
        }
        cell.positionLabel.text = posString*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(!SquadCore.premiumEnabled)
        {
            self.present(self.premiumRequiredVC, animated: true, completion: nil)
        }
        else
        {
            let player = SquadCore.selectedSquadRoster[(indexPath as NSIndexPath).row]
            var totals = self.statCache[player.objectId!]
            if(totals == nil)
            {
                totals = SquadCore.getCareerLeaders([player])
                self.statCache[player.objectId!] = totals
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Player Profile") as! ProfileVC!
            vc?.player = player
            vc?.totals = totals!.first
            self.present(vc!, animated: true, completion: nil)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let vc = segue.destination as! AddDummyVC
        vc.parentRosterVC = self
    }
    

}
