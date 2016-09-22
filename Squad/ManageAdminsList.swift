//
//  ManageAdminsList.swift
//  Squad
//
//  Created by Michael Litman on 7/14/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class ManageAdminsList: UITableViewController
{
    var data = [PFObject]()
    var checks = [Bool]()
    var checksCompare = [Bool]() //used to make sure we only update the ones that changed
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                let user = player["user"] as! PFUser
                if(user.objectId! == SquadCore.currentUser.objectId!)
                {
                    continue
                }
                data.append(player)
                let isAdmin = player["isAdmin"] as! Bool
                checks.append(isAdmin)
                checksCompare.append(isAdmin)
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func save()
    {
        for i in 0 ..< self.checks.count
        {
            if(self.checks[i] != self.checksCompare[i])
            {
                //this data has changed, resave
                let player = self.data[i]
                player["isAdmin"] = self.checks[i]
                player.saveInBackground()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let player = self.data[(indexPath as NSIndexPath).row]
        let user = player["user"] as! PFUser
        cell.textLabel?.text = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
        if(checks[(indexPath as NSIndexPath).row])
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.font = UIFont(name:"AvenirNext-Regular", size:16)
        
        /*
        cell.imageView?.maskAsCircle()
        if(user["imageName"] != nil)
        {
            let imageName = user["imageName"] as! String
            SquadCore.getImage(cell.imageView!, imageName: imageName, profileImage: true)
        }
        */
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)!
        if(self.checks[(indexPath as NSIndexPath).row])
        {
            cell.accessoryType = .none
            self.checks[(indexPath as NSIndexPath).row] = false
        }
        else
        {
            cell.accessoryType = .checkmark
            self.checks[(indexPath as NSIndexPath).row] = true
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
