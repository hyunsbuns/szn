//
//  DemoTableViewController.swift
//  Squad
//
//  Created by Steve on 2/15/16.
//  Copyright © 2016 squad. All rights reserved.
//
import UIKit
import FoldingCell
import Parse

let infrared: UIColor = UIColor( red: CGFloat(252/255.0), green: CGFloat(75/255.0), blue: CGFloat(56/255.0), alpha: CGFloat(100.0) )

class FoldScheduleVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate,  SeasonSelectorDelegate {
    
    let kCloseCellHeight: CGFloat = 160 // equal or greater foregroundView height
    let kOpenCellHeight: CGFloat = 324 // equal or greater containerView height
    
    var cellHeights = [CGFloat]()
    
    var READ_ONLY = false
    
    var kRowsCount = 0

    //@IBOutlet weak var upcomingPastSwitch: DGRunkeeperSwitch!
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    @IBOutlet weak var seasonLabel: UILabel!
    var currentSeason : PFObject!
    
    @IBOutlet weak var theTableView: UITableView!
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var chooseSeasonButton: UIButton!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var upcomingButton: UIBarButtonItem!
    
    @IBOutlet weak var pastButton: UIBarButtonItem!

    
    
    var currToggle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need this in view will appear and here just in case
        SquadCore.currentSeasonSelectorDelegate = self
        
        //Set the current active season when this screen first loads
        self.currentSeason = SquadCore.currentActiveSeason
        self.setSeasonLabel()
        
        self.currToggle = "Upcoming"
        self.setBarButtonColors()
        //Let SquadCore know about me
        SquadCore.foldingScheduleVC = self
        
        
        self.view.backgroundColor = asphaltColor
        self.toolBar.layer.backgroundColor = asphaltColor.cgColor
        
        
        
        //self.upcomingPastSwitch.titleFont = UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 12.0)
        //self.upcomingPastSwitch.backgroundColor = skwadDarkGrey
        //self.upcomingButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 16)!], forState: UIControlState.Normal)
        
        //self.pastButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 16)!], forState: UIControlState.Normal)
        
        self.dateFormatter.dateStyle = DateFormatter.Style.full
        self.dateFormatter.timeStyle = DateFormatter.Style.short
        //SquadCore.ScheduleVC_CollectionView = self.theCollectionView
        SquadCore.FoldScheduleVC_TableView = self.theTableView
        
        SquadCore.filterUpcomingEvents()
        self.updateCellHeights()
        
        //update interface elements for the current user initially, this
        //may get called again based on season changes, but we do need it
        //here to make sure non-admins can't do admin things
        self.updateActiveInterfaceElements()
        
    }
    
    func updateCellHeights()
    {
        cellHeights.removeAll()
        kRowsCount = SquadCore.selectedSquadFilteredEvents.count
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    func setBarButtonColors() {
        if(self.currToggle == "Upcoming")
        {
            self.upcomingButton.tintColor = UIColor.white
            self.pastButton.tintColor = UIColor.darkGray
            
        }
        else if(self.currToggle == "Past")
        {
            self.upcomingButton.tintColor = UIColor.darkGray
            self.pastButton.tintColor = UIColor.white    
        }
    }
    
    @IBAction func toggleButtonPressed(_ sender: UIBarButtonItem)
    {
        if(sender == self.upcomingButton)
        {
            SquadCore.filterUpcomingEvents()
            self.currToggle = "Upcoming"
            
        }
        else if(sender == self.pastButton)
        {
            SquadCore.filterPastEvents()
            self.currToggle = "Past"
        }
        self.setBarButtonColors()
        self.updateCellHeights()
        self.theTableView.reloadData()
    }
    /*
    @IBAction func upcomingPastSwitchPressed(sender: AnyObject)
    {
        if upcomingPastSwitch.selectedIndex == 0
        {
            SquadCore.filterUpcomingEvents()
        }
        else
        {
            SquadCore.filterPastEvents()
        }
        self.updateCellHeights()
        self.theTableView.reloadData()
    }
    */
    
    /*@IBAction func filterEventsChanged(sender: UISegmentedControl)
    {
    if(sender.selectedSegmentIndex == 0)
    {
    SquadCore.filterUpcomingEvents()
    }
    else
    {
    SquadCore.filterPastEvents()
    }
    self.theCollectionView.reloadData()
    }*/
    
    func updateActiveInterfaceElements()
    {
        if(self.READ_ONLY)
        {
            self.addEventButton.isEnabled = false
            self.currToggle = "PAST"
            self.upcomingButton.isEnabled = false
            //self.filterSegments.selectedSegmentIndex = 1
            //self.filterSegments.enabled = false
            SquadCore.filterPastEvents()
        }
        else
        {
            if(SquadCore.isAdmin(SquadCore.selectedSquad, user: SquadCore.currentUser))
            {
                self.addEventButton.isEnabled = true
            }
            else
            {
                self.addEventButton.isEnabled = false
            }
        
            //self.upcomingPastSwitch.selectedIndex == 0
            //self.upcomingPastSwitch.enabled = true
            
            SquadCore.filterUpcomingEvents()
        }
        self.theTableView.reloadData()
    }
    
    //adheres to SeasonSelectorDelegate
    func setSeasonLabel()
    {
        self.seasonLabel.text = self.currentSeason.value(forKey: "name") as? String
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //need this in view did load and here just in case
        SquadCore.currentSeasonSelectorDelegate = self
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SquadCore.selectedSquadFilteredEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! DemoCell
        
        // Configure the cell
        //let the cell know about its parent VC so he can present VCs
        cell.parentVC = self
        
        let currEvent = SquadCore.selectedSquadFilteredEvents[(indexPath as NSIndexPath).row]
        //let the cell know about the event PFObject
        cell.event = currEvent
        
        //cell.titleLabel.text = currEvent.objectForKey("event_type") as? String
        let dt = self.dateFormatter.string(from: currEvent.object(forKey: "date") as! Date)
        //print(dt)
        let parts = dt.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        _ = SquadCore.daysOfWeek[parts[0].substring(to: parts[0].characters.index(before: parts[0].endIndex))]
        let month = SquadCore.monthsOfYear[parts[1]]
        let day = parts[2].substring(to: parts[2].characters.index(before: parts[2].endIndex))
        _ = parts[3]
        let time = parts[5]
        let ampm = parts[6]
        //cell.dayofWeekLabel.text = dayOfWeek
        cell.dayLabel.text = day
        cell.monthLabel.text = month
        //cell.yearLabel.text = year
        cell.timeLabel.text = time
        cell.ampmLabel.text = ampm
        
        cell.opponentNameLabel.text = "\(currEvent.object(forKey: "opponent_name") as! String)"

        cell.opponentNameTopLabel.text = "\(currEvent.object(forKey: "opponent_name") as! String)"
        cell.mySkwadLabel.text = "\(SquadCore.selectedSquad.value(forKey: "name") as! String)"
        cell.mySkwadTopLabel.text = "\(SquadCore.selectedSquad.value(forKey: "name") as! String)"
        //cell.locationLabel.text = currEvent.objectForKey("location") as? String
        cell.locationLabel2.text = currEvent.object(forKey: "location") as? String
        
        //add the map
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LocationPlotterVC") as! LocationPlotterVC
        vc.mapView = cell.map
        let lat = currEvent.value(forKey: "lat") as! CLLocationDegrees
        let lon = currEvent.value(forKey: "lon") as! CLLocationDegrees
        vc.setLocation(lat, lon: lon)
        vc.updateMap()
        cell.lat = lat
        cell.lon = lon
        
        let score = SquadCore.getCurrentScore(currEvent)
        let squadScore = score?.value(forKey: "score") as! Int
        let opponentScore = score?.value(forKey: "opponent_score") as! Int
        
        cell.mySkwadScore.text = "\(squadScore)"
        cell.mySkwadScoreTop.text = "\(squadScore)"
        cell.opponentScoreLabel.text = "\(opponentScore)"
        cell.opponentScoreTop.text = "\(opponentScore)"
        
        if opponentScore == 0 && squadScore == 0 {
            cell.winLossLabel.text = "VS"
        } else if opponentScore > squadScore {
            cell.winLossLabel.text = "L"
        } else if opponentScore < squadScore {
            cell.winLossLabel.text = "W"
        } else {
            cell.winLossLabel.text = "T"
        }
        
        if(SquadCore.selectedSquad["imageName"] != nil)
        {
            let imageName = SquadCore.selectedSquad["imageName"] as! String
            SquadCore.getImage(iv: cell.myTeamImage, imageName: imageName, profileImage: false)
        }
        
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            
            if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    //this is a delegate method for the popover
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController)
    {
        //This centers the popover in the middle of the seasonLabel and directly off the bottom of it
        popoverPresentationController.sourceRect = CGRect(x: self.seasonLabel.frame.size.width/2, y: self.seasonLabel.frame.height, width: 0, height: 0)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if(segue.identifier != nil && segue.identifier! == "SeasonPopover")
        {
            let popPC = segue.destination.popoverPresentationController
            
            popPC!.delegate = self;
        }
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
