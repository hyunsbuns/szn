//
//  CareerLeadersTVC.swift
//  Squad
//
//  Created by Michael Litman on 8/4/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Spring

class CareerLeadersTVC: UITableViewController
{
    var currStat = "N/A"
    var didGetTotals = false
    var careerTotals = [StatTotals]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getHeight() -> CGFloat
    {
        return self.tableView.contentSize.height
    }
    
    func sortTotals()
    {
        if(!SquadCore.isStatCalculated(self.currStat))
        {
            self.careerTotals = SquadCore.sortStatTotalsGivenStat(self.currStat, statTotals: self.careerTotals)
        }
        else
        {
            self.careerTotals = SquadCore.sortStatAveragesGivenStat(self.currStat, statTotals: self.careerTotals)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if(!self.didGetTotals)
        {
            self.refreshData()
            self.tableView.reloadData()
        }
    }
    
    func refreshData()
    {
        //self.seasonTotals = SquadCore.currentStatTotals
        //let squadcore know about these totals for the SeasonTotals on SznVC
        
        self.didGetTotals = true
        self.sortTotals()
        self.tableView.reloadData()
    }
    
    func setStat(_ stat: String)
    {
        self.currStat = stat
        self.sortTotals()
        self.tableView.reloadData()
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
        return self.careerTotals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SeasonLeadersTVCell
        
        // Configure the cell...
        let total = self.careerTotals[(indexPath as NSIndexPath).row]
        let player = total.player
        if(player["user"] != nil)
        {
            let user = player["user"] as! PFUser
            
            cell.playerNameLabel.text = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
            
            let imageName = user["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: cell.profileImage, imageName: imageName as! String, profileImage: true)
            }
        }
        else
        {
            cell.playerNameLabel.text = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
            
            let imageName = player["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: cell.profileImage, imageName: imageName as! String, profileImage: true)
            }
            
        }
        var value = total.getAverageForStat(self.currStat)
        if(!SquadCore.isStatCalculated(self.currStat))
        {
            value = total.getTotalForStat(self.currStat)
            let intValue = Int(value)
            let diff = value - Double(intValue)
            if(diff == 0.0)
            {
                cell.statCountLabel.text = "\(Int(value))"
            }
            else
            {
                cell.statCountLabel.text = "\(value)"
            }
        }
        else
        {
            if(value < 1 && value != 0.0)
            {
                let s = String(format:"%.3f", value)
                cell.statCountLabel.text = s.substring(from: s.characters.index(after: s.startIndex))
            }
            else
            {
                let s = String(format:"%.1f", value)
                cell.statCountLabel.text = s
            }
        }
        cell.statCountLabel.animation = "squeezeLeft"
        cell.statCountLabel.delay = 0.3
        cell.statCountLabel.animate()
        
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
