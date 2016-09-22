//
//  WalletActivityList.swift
//  Squad
//
//  Created by Michael Litman on 8/14/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class WalletActivityList: UITableViewController
{
    var data = [PFObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let obj = self.data[(indexPath as NSIndexPath).row]
        let player = obj["player"] as! PFObject
        let type = obj["type"] as! String
        let amount = obj["amount"] as! Int
        player.fetchIfNeededInBackground { (fetchedPlayer: PFObject?, error: Error?) in
            if(error == nil)
            {
                //get name
                if(fetchedPlayer!["user"] == nil)
                {
                    let fname = fetchedPlayer!["firstName"] as! String
                    let lname = fetchedPlayer!["lastName"] as! String
                    cell.textLabel?.text = "\(fname) \(lname)"
                }
                else
                {
                    let user = fetchedPlayer!["user"] as! PFUser
                    user.fetchIfNeededInBackground(block: { (fetchedUser: PFObject?, error: Error?) in
                        
                        //get image
                        if(fetchedUser!["imageName"] != nil)
                        {
                            let imageName = fetchedUser!["imageName"] as! String
                            SquadCore.getImage(iv: cell.imageView!, imageName: imageName, profileImage: true)
                        }

                        let fname = fetchedUser!["firstName"] as! String
                        let lname = fetchedUser!["lastName"] as! String
                        cell.textLabel?.text = "\(fname) \(lname)"
                    })
                }
            }
        }
        if(type == "credit")
        {
            cell.detailTextLabel?.text = "bought \(amount) tokens"
        }
        else
        {
            cell.detailTextLabel?.text = "spent \(amount) tokens"
        }
        return cell
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
