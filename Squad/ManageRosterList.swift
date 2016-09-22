//
//  ManageRosterList.swift
//  Squad
//
//  Created by Michael Litman on 7/19/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class ManageRosterList: UITableViewController
{
    var data = [PFObject]()
    var checkMarks = [Bool]()
    override func viewDidLoad()
    {
        super.viewDidLoad()

        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil && (player["user"] as! PFUser).objectId! != SquadCore.currentUser.objectId!)
            {
                self.data.append(player)
                self.checkMarks.append(false)
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let player = self.data[(indexPath as NSIndexPath).row]
        let user = player["user"]
        var name = ""
        if(user == nil)
        {
            let fname = player["firstName"] as! String
            let lname = player["lastName"] as! String
            name = "\(fname) \(lname)"
            
        }
        else
        {
            name = "\((user as! PFUser)["firstName"] as! String) \((user as! PFUser)["lastName"] as! String)"
        }
        
        cell.textLabel?.text = name
        cell.textLabel?.font = UIFont(name:"AvenirNext-Regular", size:16)
        
        if(self.checkMarks[(indexPath as NSIndexPath).row])
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.checkMarks[(indexPath as NSIndexPath).row] = !self.checkMarks[(indexPath as NSIndexPath).row]
        self.tableView.reloadData()
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
