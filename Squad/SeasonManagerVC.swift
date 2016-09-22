//
//  SeasonManagerVC.swift
//  Squad
//
//  Created by Michael Litman on 1/19/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class SeasonManagerVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var theTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SquadCore.seasonManagerTableView = self.theTableView
        
        //tune the size of the popover here
        let minRows = 4
        let maxRows = 8
        let width = 300
        var height = minRows * 50
        if(SquadCore.seasonManagerSeasonList.count > 4)
        {
            if(SquadCore.seasonManagerSeasonList.count < maxRows)
            {
                height = SquadCore.seasonManagerSeasonList.count * 50
            }
            else
            {
                height = maxRows * 50
            }
        }
        
        self.preferredContentSize = CGSize(width: width, height: height)
        
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

    func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       return SquadCore.seasonManagerSeasonList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel!.text = SquadCore.seasonManagerSeasonList[(indexPath as NSIndexPath).row].value(forKey: "name") as? String
        if(!(SquadCore.seasonManagerSeasonList[(indexPath as NSIndexPath).row].value(forKey: "isActive") as! Bool))
        {
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if((indexPath as NSIndexPath).row < SquadCore.seasonManagerSeasonList.count)
        {
            SquadCore.currentSeasonSelectorDelegate.currentSeason = SquadCore.seasonManagerSeasonList[(indexPath as NSIndexPath).row]
            SquadCore.currentSeasonSelectorDelegate.setSeasonLabel()
            SquadCore.filterUpcomingEvents()
            
            if(SquadCore.currentSeasonSelectorDelegate is FoldScheduleVC)
            {
                let vc = SquadCore.currentSeasonSelectorDelegate as! FoldScheduleVC
                vc.currToggle = "Upcoming"
                vc.setBarButtonColors()
                vc.updateCellHeights()
                vc.theTableView.reloadData()
            }
            else if(SquadCore.currentSeasonSelectorDelegate is SznVC)
            {
                //do szn stuff
                _ = SquadCore.currentSeasonSelectorDelegate as! SznVC
            }
            //determine if the delegate should be in read_only or read/write mode
            if(SquadCore.seasonManagerSeasonList[(indexPath as NSIndexPath).row].value(forKey: "isActive") as! Bool)
            {
                SquadCore.currentSeasonSelectorDelegate.READ_ONLY = false
            }
            else
            {
                SquadCore.currentSeasonSelectorDelegate.READ_ONLY = true
            }
            SquadCore.currentSeasonSelectorDelegate.updateActiveInterfaceElements()
            
            self.dismiss(animated: true, completion: nil)
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
