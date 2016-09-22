//
//  RollCallVC.swift
//  Squad
//
//  Created by Steve on 1/10/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Spring
import ParseUI
import Parse

class RollCallVC: UIViewController
{
    @IBOutlet weak var rollCallButton: UIBarButtonItem!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var imInButton: SpringButton!
    @IBOutlet weak var imOutButton: SpringButton!
    @IBOutlet weak var gonnaBeLateButton: SpringButton!
    @IBOutlet weak var injuredButton: SpringButton!
    @IBOutlet weak var onVacationButton: SpringButton!
    @IBOutlet weak var idkYetButton: SpringButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    var opponentName : String!
    var date_time : String!
    var event: PFObject!
    var player : PFObject!
    var user : PFUser!
    var uid : String!
    var isPushResponse = false
    var theSpringButtons : [SpringButton]!
    var imageName = "N/A"
    var data : [PFObject]!
    var rollCallData = [PFObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if(SquadCore.selectedSquad != nil && SquadCore.isAdmin(SquadCore.selectedSquad, user: SquadCore.currentUser))
        {
            self.rollCallButton.isEnabled = true
        }
        else
        {
            self.rollCallButton.isEnabled = false
        }
        
        if(!isPushResponse)
        {
            let temp = SquadCore.selectedSquadRoster
            self.data = [PFObject]()
            for obj in temp
            {
                if(obj["dummy"] as! Bool == false)
                {
                    self.data.append(obj)
                }
            }
            
            self.user = SquadCore.currentUser
            for player in self.data
            {
                if(player["user"] != nil && (player["user"] as! PFUser).objectId! == self.user.objectId!)
                {
                    self.player = player
                }
            }
            self.getCurrentRollCall()
        }
        else
        {
            let owner = event["owner_id"] as! PFObject
            let query = PFQuery(className: "Player")
            query.whereKey("squad", equalTo: owner)
            query.whereKey("dummy", equalTo: false)
            query.includeKey("user")
            self.data = [PFObject]()
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if(error == nil)
                {
                    self.data = objects
                    for player in self.data
                    {
                        if((player["user"] as! PFUser).objectId == self.uid)
                        {
                            self.player = player
                            self.user = player["user"] as! PFUser
                        }
                    }
                    self.getCurrentRollCall()
                }
            })
        }
        theSpringButtons = [imInButton, imOutButton, gonnaBeLateButton, injuredButton, onVacationButton, idkYetButton]
        
        self.opponentLabel.text = "\(self.opponentName)"
        self.dateTimeLabel.text = self.date_time
        
        /*self.navBar.topItem?.title = "ROLL CALL"
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.shadowImage = UIImage()
        self.navBar.translucent = true
        */
        self.view.backgroundColor = skwadDarkGrey
        
        //self.tableView.layer.cornerRadius = 10
        
        /*let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [skwadDarkGrey.CGColor, UIColor.blackColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        */
        
        imInButton.layer.borderWidth = 1
        imInButton.layer.borderColor = mintColor.cgColor
        imInButton.layer.cornerRadius = min(imInButton.layer.frame.width, imInButton.layer.frame.height)/2
        imInButton.layer.masksToBounds = true
        imInButton.layer.backgroundColor = UIColor.clear.cgColor
        imInButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        imInButton.setTitleColor(mintColor, for: UIControlState())
        
        imOutButton.layer.borderWidth = 1
        imOutButton.layer.borderColor = salmonColor.cgColor
        imOutButton.layer.cornerRadius = min(imOutButton.layer.frame.width, imOutButton.layer.frame.height)/2
        imOutButton.layer.masksToBounds = true
        imOutButton.layer.backgroundColor = UIColor.clear.cgColor
        imOutButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        imOutButton.setTitleColor(salmonColor, for: UIControlState())
        
        idkYetButton.layer.borderWidth = 1
        idkYetButton.layer.borderColor = aquaColor.cgColor
        idkYetButton.layer.cornerRadius = min(idkYetButton.layer.frame.width, idkYetButton.layer.frame.height)/2
        idkYetButton.layer.masksToBounds = true
        idkYetButton.layer.backgroundColor = UIColor.clear.cgColor
        idkYetButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        idkYetButton.setTitleColor(aquaColor, for: UIControlState())
        
        injuredButton.layer.borderWidth = 1
        injuredButton.layer.borderColor = neonOrange.cgColor
        injuredButton.layer.cornerRadius = min(injuredButton.layer.frame.width, injuredButton.layer.frame.height)/2
        injuredButton.layer.masksToBounds = true
        injuredButton.layer.backgroundColor = UIColor.clear.cgColor
        injuredButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        injuredButton.setTitleColor(neonOrange, for: UIControlState())
        
        onVacationButton.layer.borderWidth = 1
        onVacationButton.layer.borderColor = grapeColor.cgColor
        onVacationButton.layer.cornerRadius = min(onVacationButton.layer.frame.width, imInButton.layer.frame.height)/2
        onVacationButton.layer.masksToBounds = true
        onVacationButton.layer.backgroundColor = UIColor.clear.cgColor
        onVacationButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        onVacationButton.setTitleColor(grapeColor, for: UIControlState())
        
        gonnaBeLateButton.layer.borderWidth = 1
        gonnaBeLateButton.layer.borderColor = skyBlueColor.cgColor
        gonnaBeLateButton.layer.cornerRadius = min(gonnaBeLateButton.layer.frame.width, gonnaBeLateButton.layer.frame.height)/2
        gonnaBeLateButton.layer.masksToBounds = true
        gonnaBeLateButton.layer.backgroundColor = UIColor.clear.cgColor
        gonnaBeLateButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getCurrentRollCall()
    {
        let query = PFQuery(className: "RollCall")
        //print(self.event.debugDescription)
        query.whereKey("event_id", equalTo: self.event)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if(error != nil)
            {
                self.rollCallData = [PFObject]()
            }
            else
            {
                self.rollCallData = objects!
                let myStatus = self.getStatusForPlayer(self.player)
                self.toggleButtons(myStatus)
                self.tableView.reloadData()
            }
        }
    }
    
    func toggleButtons(_ status: String)
    {
        if(status == "N/A")
        {
            return
        }
        self.imageName = status
        var sender = imInButton
        var color = mintColor.cgColor

        if(status == "rollcall-imout")
        {
            sender = imOutButton
            color = salmonColor.cgColor
        }
        else if(status == "rollcall-late")
        {
            sender = gonnaBeLateButton
            color = skyBlueColor.cgColor
        }
        else if(status == "rollcall-injured")
        {
            sender = injuredButton
            color = neonOrange.cgColor
        }
        else if(status == "rollcall-vacation")
        {
            sender = onVacationButton
            color = grapeColor.cgColor
        }
        else if(status == "rollcall-idk")
        {
            sender = idkYetButton
            color = aquaColor.cgColor
        }
        
        self.popOffAllBut(sender!)
        self.setNormalTextColor(sender!)
        sender?.layer.backgroundColor = color
        sender?.setTitleColor(UIColor.white, for: UIControlState())
        sender?.animation = "pop"
        sender?.animate()
    }
    
    func getStatusForPlayer(_ player: PFObject) -> String
    {
        //NOT RETURNING CORRECT STATUS
        for obj in self.rollCallData
        {
            let p = obj["player"] as! PFObject
            if(p.objectId! == player.objectId!)
            {
                return obj["status"] as! String
            }
        }
        return "N/A"
    }
    
    @IBAction func sendRollCallButtonPressed(_ sender: AnyObject)
    {
        SquadCore.rollCall(self.event)
        let alert = UIAlertController(title: "Success", message: "The Roll Call Was Sent", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setNormalTextColor(_ button: SpringButton)
    {
        for sb in self.theSpringButtons
        {
            if (sb == imInButton)
            {
                imOutButton.setTitleColor(salmonColor, for: UIControlState())
                idkYetButton.setTitleColor(aquaColor, for: UIControlState())
                injuredButton.setTitleColor(neonOrange, for: UIControlState())
                onVacationButton.setTitleColor(grapeColor, for: UIControlState())
                gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())
            }
            else if (sb == imOutButton)
            {
                imInButton.setTitleColor(mintColor, for: UIControlState())
                idkYetButton.setTitleColor(aquaColor, for: UIControlState())
                injuredButton.setTitleColor(neonOrange, for: UIControlState())
                onVacationButton.setTitleColor(grapeColor, for: UIControlState())
                gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())
            }
            else if (sb == idkYetButton)
            {
                imInButton.setTitleColor(mintColor, for: UIControlState())
                imOutButton.setTitleColor(salmonColor, for: UIControlState())
                injuredButton.setTitleColor(neonOrange, for: UIControlState())
                onVacationButton.setTitleColor(grapeColor, for: UIControlState())
                gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())
            }
            else if (sb == injuredButton)
            {
                imInButton.setTitleColor(mintColor, for: UIControlState())
                imOutButton.setTitleColor(salmonColor, for: UIControlState())
                idkYetButton.setTitleColor(aquaColor, for: UIControlState())
                onVacationButton.setTitleColor(grapeColor, for: UIControlState())
                gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())
            }
            else if (sb == onVacationButton)
            {
                imInButton.setTitleColor(mintColor, for: UIControlState())
                imOutButton.setTitleColor(salmonColor, for: UIControlState())
                idkYetButton.setTitleColor(aquaColor, for: UIControlState())
                injuredButton.setTitleColor(neonOrange, for: UIControlState())
                gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())
            }
            else
            {
                imInButton.setTitleColor(mintColor, for: UIControlState())
                imOutButton.setTitleColor(salmonColor, for: UIControlState())
                idkYetButton.setTitleColor(aquaColor, for: UIControlState())
                injuredButton.setTitleColor(neonOrange, for: UIControlState())
                onVacationButton.setTitleColor(grapeColor, for: UIControlState())
                
            }
            
        }
        
        
    }
    
    func popOffAllBut(_ button: SpringButton)
    {
        for sb in self.theSpringButtons
        {
            if(sb == button)
            {
                continue
            }
            sb.layer.backgroundColor = UIColor.clear.cgColor
            //sb.animation = "pop"
            //sb.animate()
        }
    }
    
    func saveStatus()
    {
        if(self.imageName != "N/A")
        {
            SquadCore.updateRollCallStatus(self.player, event: self.event, status: self.imageName)
        }
    }
    
    func resetButtons()
    {
        imInButton.setTitleColor(mintColor, for: UIControlState())
        imOutButton.setTitleColor(salmonColor, for: UIControlState())
        idkYetButton.setTitleColor(aquaColor, for: UIControlState())
        injuredButton.setTitleColor(neonOrange, for: UIControlState())
        onVacationButton.setTitleColor(grapeColor, for: UIControlState())
        gonnaBeLateButton.setTitleColor(skyBlueColor, for: UIControlState())
        
        imOutButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        idkYetButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        injuredButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        onVacationButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        gonnaBeLateButton.setTitleColor(UIColor.white, for: UIControlState.selected)
        gonnaBeLateButton.setTitleColor(UIColor.white, for: UIControlState.selected)
    }
    
    @IBAction func imInButtonPressed(_ sender: SpringButton)
    {
        self.resetButtons()
        self.imageName = "rollcall-imin"
        self.popOffAllBut(sender)
        self.setNormalTextColor(sender)
        self.imInButton.layer.backgroundColor = mintColor.cgColor
        sender.setTitleColor(UIColor.white, for: UIControlState())
        self.imInButton.animation = "pop"
        self.imInButton.animate()
        self.tableView.reloadData()
        self.saveStatus()
    }
    
    @IBAction func imOutButtonPressed(_ sender: SpringButton)
    {
        self.resetButtons()
        self.imageName = "rollcall-imout"
        self.popOffAllBut(sender)
        self.imOutButton.layer.backgroundColor = salmonColor.cgColor
        sender.setTitleColor(UIColor.white, for: UIControlState())
        self.imOutButton.animation = "pop"
        self.imOutButton.animate()
        self.tableView.reloadData()
        self.saveStatus()
    }
    
    @IBAction func idkYetButtonPressed(_ sender: SpringButton) {
        self.resetButtons()
        self.imageName = "rollcall-idk"
        self.popOffAllBut(sender)
        self.idkYetButton.layer.backgroundColor = aquaColor.cgColor
        sender.setTitleColor(UIColor.white, for: UIControlState())
        
        self.idkYetButton.animation = "pop"
        self.idkYetButton.animate()
        self.tableView.reloadData()
        self.saveStatus()
    }
    
    @IBAction func injuredButtonPressed(_ sender: SpringButton) {
        self.resetButtons()
        self.imageName = "rollcall-injured"
        self.popOffAllBut(sender)
        self.injuredButton.layer.backgroundColor = neonOrange.cgColor
        sender.setTitleColor(UIColor.white, for: UIControlState())
        
        self.injuredButton.animation = "pop"
        self.injuredButton.animate()
        self.tableView.reloadData()
        self.saveStatus()
    }
    
    @IBAction func onVacationButtonPressed(_ sender: SpringButton) {
        self.resetButtons()
        self.imageName = "rollcall-vacation"
        self.popOffAllBut(sender)
        self.onVacationButton.layer.backgroundColor = grapeColor.cgColor
        sender.setTitleColor(UIColor.white, for: UIControlState())
        
        self.onVacationButton.animation = "pop"
        self.onVacationButton.animate()
        self.tableView.reloadData()
        self.saveStatus()
    }
    
    @IBAction func gonnaBeLateButtonPressed(_ sender: SpringButton) {
        self.resetButtons()
        self.imageName = "rollcall-late"
        self.popOffAllBut(sender)
        self.gonnaBeLateButton.layer.backgroundColor = skyBlueColor.cgColor
        sender.setTitleColor(UIColor.white, for: UIControlState())
        
        self.gonnaBeLateButton.animation = "pop"
        self.gonnaBeLateButton.animate()
        self.tableView.reloadData()
        self.saveStatus()
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RollCallTVCell
        
        // Configure the cell...
        let user = self.data[(indexPath as NSIndexPath).row]["user"] as! PFUser
        //try! user.fetchIfNeeded()
        let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
        cell.nameLabel.text = name
        SquadCore.getImage(iv: cell.profileImage, imageName: user["imageName"] as! String, profileImage: true)
        
        //cell.profileImage.file = user["profilePhoto") as? PFFile
        //cell.profileImage.loadInBackground()
        
        let statusImage = self.getStatusForPlayer(self.data[(indexPath as NSIndexPath).row])
        if(statusImage != "N/A")
        {
            if(self.player.objectId! == self.data[(indexPath as NSIndexPath).row].objectId!)
            {
                cell.rcIcon.image = UIImage(named: self.imageName)
            }
            else
            {
                cell.rcIcon.image = UIImage(named: statusImage)
            }
            cell.rcIcon.isHidden = false
        }
        else
        {
            //no status set for this player
            cell.rcIcon.isHidden = true
        }
        /*
        if indexPath.row == 0 {
            cell.rcIcon.image = UIImage(named:"rollcall-imin")
        }
        else if indexPath.row == 1 {
            cell.rcIcon.image = UIImage(named: "rollcall-imout")
        }
        else if indexPath.row == 2 {
            cell.rcIcon.image = UIImage(named: "rollcall-idk")
        }
        else if indexPath.row == 3 {
            cell.rcIcon.image = UIImage(named: "rollcall-injured")
        }
        else if indexPath.row == 4 {
            cell.rcIcon.image = UIImage(named: "rollcall-late")
        }
        else if indexPath.row == 5 {
            cell.rcIcon.image = UIImage(named: "rollcall-vacation")
        }
        */
        return cell
        
        
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
