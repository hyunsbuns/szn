//
//  SquadHomeViewController.swift
//  Squad
//
//  Created by Steve on 8/9/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKShareKit

class SquadHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //@IBOutlet weak var teamImage: PFImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var teamRecordLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var announcementsCVC : AnnouncementsCVC!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //determine if premium is enabled
        SquadCore.setPremium(SquadCore.selectedSquad["premium_expiration"] as! Date)
        
        self.view.backgroundColor = asphaltColor
        
        
        let owner = SquadCore.selectedSquad["owner_id"] as! PFUser
        if(SquadCore.currentUser.objectId! == owner.objectId!)
        {
            //self.postButton.hidden = false
        }
        else
        {
            //self.postButton.hidden = true
        }
        
        if(SquadCore.selectedSquad["imageName"] != nil)
        {
            let imageName = SquadCore.selectedSquad["imageName"] as! String
            //SquadCore.getImage(iv: self.teamImage, imageName: imageName, profileImage: false)
        }
        
        self.teamNameLabel.text = "\((SquadCore.selectedSquad.value(forKey: "name")! as AnyObject).uppercased as String)"
        
        self.view.isUserInteractionEnabled = true;
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let allEvents = SquadCore.selectedSquadEvents
        var seasonEvents = [PFObject]()
        var wins = 0
        var ties = 0
        var losses = 0
        for event in allEvents!
        {
            let eventSeason = event["season"] as! PFObject
            if(eventSeason.objectId! == SquadCore.currentActiveSeason.objectId!)
            {
                let eventDate = event["date"] as! Date
                let now = Date()
                if(eventDate.compare(now) == ComparisonResult.orderedAscending)
                {
                    seasonEvents.append(event)
                    for score in SquadCore.selectedSquadEventScores
                    {
                        let scoreEvent = score["event"] as! PFObject
                        if(scoreEvent.objectId! == event.objectId!)
                        {
                            let ourScore = score["score"] as! Int
                            let opponentScore = score["opponent_score"] as! Int
                            
                            if(ourScore > opponentScore)
                            {
                                wins += 1
                            }
                            else if(ourScore < opponentScore)
                            {
                                losses += 1
                            }
                            else
                            {
                                ties += 1
                            }
                            //we found our score, so get out of this search loop
                            break
                        }
                    }
                }
            }
        }
        
        //we have our record
        if(ties == 0)
        {
            self.teamRecordLabel.text = "\(wins) - \(losses)"
        }
        else
        {
            self.teamRecordLabel.text = "\(wins) - \(losses) - \(ties)"
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 230.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            return cell
        }
        else if(indexPath.row == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            return cell
        }

    }
    
    
    /*
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of items
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if(indexPath.row == 0)
        {
            let invitePlayersCell = collectionView.dequeueReusableCellWithReuseIdentifier("invitePlayersCell", forIndexPath: indexPath)
            invitePlayersCell.layer.cornerRadius = 5
            
            return invitePlayersCell
        }
        else if(indexPath.row == 1)
        {
            let buyTokensCell = collectionView.dequeueReusableCellWithReuseIdentifier("buyTokensCell", forIndexPath: indexPath)
            buyTokensCell.layer.cornerRadius = 5
            buyTokensCell.layer.borderColor = UIColor.lightGrayColor().CGColor
            buyTokensCell.layer.borderWidth = 0.5
            
            return buyTokensCell
        }
        else
        {
            let learnMoreCell = collectionView.dequeueReusableCellWithReuseIdentifier("learnMoreCell", forIndexPath: indexPath)
            
            // Configure the cell
            learnMoreCell.layer.cornerRadius = 5
            
            return learnMoreCell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if(indexPath.row == 0)
        {
            //do create squad stuff
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateSquadNavController") as! UINavigationController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else if(indexPath.row == 1)
        {
            //do join squad stuff
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("JoinSquadVC") as! JoinSquadVC
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else
        {
            //instantiate load screen
            let loadingVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoadingVC")
            
            //position it relative to the current view
            let newX = (self.view.frame.size.width/2) - 50
            let newY = (self.view.frame.size.height/2) - 50
            loadingVC!.view.frame = CGRectMake(newX, newY, 300, 300)
            
            //place it on the screen using the main queue
            self.view.addSubview(loadingVC!.view)
            
            //wrap anything that is slow loading in a dispatch_async on global queue (NOT MAIN QUEUE)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
            {
                SquadCore.selectedSquad = SquadCore.theSquads[indexPath.row-2]
                let sport = SquadCore.selectedSquad["sport"] as! PFObject
                try! sport.fetch()
                SquadCore.getPlayer(SquadCore.currentUser, squad: SquadCore.selectedSquad)
                SquadCore.selectedSquadEvents = SquadCore.getEventsGivenSquad(SquadCore.selectedSquad)
                //print(SquadCore.selectedSquadEvents.debugDescription)
                SquadCore.selectedSquadEventScores = SquadCore.getEventScoresGivenEvents(SquadCore.selectedSquadEvents)
                SquadCore.getMessagesForSquad(SquadCore.selectedSquad)
                SquadCore.getSquadStats(SquadCore.selectedSquad)
                SquadCore.getSquadRoster(SquadCore.selectedSquad)
                SquadCore.seasonManagerSeasonList = SquadCore.getSquadSeasons(SquadCore.selectedSquad)
                //get the active season (Note: this assumes that we already have our list of seasons above)
                SquadCore.currentActiveSeason = SquadCore.getActiveSeason(SquadCore.selectedSquad)
                
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SquadCollectionViewCell
                SquadCore.currTeamImage = cell.teamImage
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SquadTabBarController") as! UITabBarController
                self.presentViewController(vc, animated: true, completion: nil)
                
                //at the very end after the loading is done, make the load screen go away using the mainQueue
                dispatch_async(dispatch_get_main_queue(), {
                    loadingVC!.view.removeFromSuperview()
                    self.view.setNeedsDisplay()
                })
            }
        }
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier != nil)
        {
            if(segue.identifier == "Announcement Embed")
            {
                self.announcementsCVC = segue.destination as! AnnouncementsCVC
            }
            else if(segue.identifier == "New Announcement")
            {
                let vc = segue.destination as! NewAnnouncementVC
                vc.announcementsCVC = self.announcementsCVC
            }
        }
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
