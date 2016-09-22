//
//  SettingsTVC.swift
//  Squad
//
//  Created by Michael Litman on 7/12/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class SettingsTVC: UITableViewController
{
    let everyoneData = ["Edit Profile", "Back to My Squads", "Change Password", "Log Out"]
    let ownerData = ["Assign Admins", "Edit Team Profile", "Kick Player", "Start New Season"]
    let possibleSectionNames = ["Everyone", "Admin", "Owner"]
    var actualSectionNames = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let owner = SquadCore.selectedSquad["owner_id"] as! PFUser
        if(owner.objectId! == SquadCore.currentUser.objectId!)
        {
            self.actualSectionNames.append(self.possibleSectionNames[2])
        }
        self.actualSectionNames.append(self.possibleSectionNames[0])
        
        //self.view.backgroundColor = nightColor
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.actualSectionNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        if(self.actualSectionNames[section] == "Everyone")
        {
            return self.everyoneData.count
        }
        else if(self.actualSectionNames[section] == "Owner")
        {
            return self.ownerData.count
        }
        else
        {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.actualSectionNames[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        //header.contentView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0) //make the background color light blue
        //header.textLabel!.textColor = UIColor.white //make the text white
        header.textLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        //header.alpha = 0.5 //make the header transparent
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)

        // Configure the cell...
        if(self.actualSectionNames[(indexPath as NSIndexPath).section] == "Everyone")
        {
            cell.textLabel?.text = everyoneData[(indexPath as NSIndexPath).row]
        }
        else if(self.actualSectionNames[(indexPath as NSIndexPath).section] == "Owner")
        {
            cell.textLabel?.text = ownerData[(indexPath as NSIndexPath).row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(self.actualSectionNames[(indexPath as NSIndexPath).section] == "Everyone")
        {
            if(self.everyoneData[(indexPath as NSIndexPath).row] == "Edit Profile")
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(self.everyoneData[(indexPath as NSIndexPath).row] == "Back to My Squads")
            {
                SquadCore.mainVC.dismiss(animated: true, completion: nil)
            }
            else if(self.everyoneData[(indexPath as NSIndexPath).row] == "Change Password")
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(self.everyoneData[(indexPath as NSIndexPath).row] == "Log Out")
            {
                PFUser.logOutInBackground()
                SquadCore.onboardVC.dismiss(animated: true, completion: nil)
            }
        }
        else if(self.actualSectionNames[(indexPath as NSIndexPath).section] == "Owner")
        {
            if(self.ownerData[(indexPath as NSIndexPath).row] == "Assign Admins")
            {
                //show the admins page
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManageAdminsVC") as! ManageAdminsVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(self.ownerData[(indexPath as NSIndexPath).row] == "Edit Team Profile")
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TeamProfileVC") as! TeamProfileVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(self.ownerData[(indexPath as NSIndexPath).row] == "Kick Player")
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManageRosterVC") as! ManageRosterVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(self.ownerData[(indexPath as NSIndexPath).row] == "Start New Season")
            {
                let alert = UIAlertController(title: "Warning", message: "Starting a new season will archive the existing season and set this new season as active.  This can NOT be undone.  Do you want to proceed?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "StartNewSeasonVC") as! StartNewSeasonVC
                    self.present(vc, animated: true, completion: nil)
                })
                
                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
