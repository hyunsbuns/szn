//
//  MainVC.swift
//  Squad
//
//  Created by Michael Litman on 11/19/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse

let goldColor: UIColor = UIColor( red: CGFloat(184/255.0), green: CGFloat(170/255.0), blue: CGFloat(108/255.0), alpha: CGFloat(100.0) )

let asphaltColor: UIColor = UIColor( red: CGFloat(28/255.0), green: CGFloat(28/255.0), blue: CGFloat(31/255.0), alpha: CGFloat(100.0) )

let nightColor: UIColor = UIColor( red: CGFloat(18/255.0), green: CGFloat(19/255.0), blue: CGFloat(20/255.0), alpha: CGFloat(100.0) )

let pigeonColor: UIColor = UIColor( red: CGFloat(136/255.0), green: CGFloat(137/255.0), blue: CGFloat(140/255.0), alpha: CGFloat(100.0) )


let mintColor: UIColor = UIColor( red: CGFloat(62/255.0), green: CGFloat(220/255.0), blue: CGFloat(172/255.0), alpha: CGFloat(100.0) )

let aquaColor: UIColor = UIColor( red: CGFloat(0/255.0), green: CGFloat(128/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(100.0) )

let neonOrange: UIColor = UIColor( red: CGFloat(255/255.0), green: CGFloat(114/255.0), blue: CGFloat(76/255.0), alpha: CGFloat(100.0) )

let salmonColor: UIColor = UIColor( red: CGFloat(255/255.0), green: CGFloat(102/255.0), blue: CGFloat(102/255.0), alpha: CGFloat(100.0) )

let grapeColor: UIColor = UIColor( red: CGFloat(62/255.0), green: CGFloat(53/255.0), blue: CGFloat(148/255.0), alpha: CGFloat(100.0) )

let skyBlueColor: UIColor = UIColor( red: CGFloat(16/255.0), green: CGFloat(210/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(100.0) )


let skwadDarkGrey: UIColor = UIColor( red: CGFloat(12/255.0), green: CGFloat(12/255.0), blue: CGFloat(12/255.0), alpha: CGFloat(100.0) )

let LGColor: UIColor = UIColor( red: CGFloat(208/255.0), green: CGFloat(208/255.0), blue: CGFloat(208/255.0), alpha: CGFloat(100.0) )

let tungstenColor: UIColor = UIColor( red: CGFloat(35/255.0), green: CGFloat(35/255.0), blue: CGFloat(35/255.0), alpha: CGFloat(100.0) )



class MainVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var cv: UICollectionView!
    //@IBOutlet weak var homeBG: UIImageView!
    
    //@IBOutlet weak var navBar: UINavigationBar!
    
    //@IBOutlet weak var createSkwadButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SquadCore.mainVC = self
        
        //make the storyboard global in case we need it in non-vcs
        SquadCore.storyBoard = self.storyboard
        
        /*self.navBar.topItem?.title = ""
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.shadowImage = UIImage()
        self.navBar.translucent = true*/
        
        //createSkwadButton.layer.cornerRadius = min(createSkwadButton.layer.frame.width, createSkwadButton.layer.frame.height)/2
        //createSkwadButton.layer.masksToBounds = true
        
        
        //let gradient: CAGradientLayer = CAGradientLayer()
        //gradient.frame = homeBG.bounds
        //gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        //homeBG.layer.insertSublayer(gradient, atIndex: 0)
        
        
        SquadCore.theSquadsCollectionView = self.cv
        
        //homeBG.clipsToBounds = true
    
    }

    @IBAction func logoutButtonPressed(_ sender: AnyObject)
    {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of items
        print(SquadCore.theSquads.count)
        return SquadCore.theSquads.count+2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if((indexPath as NSIndexPath).row == 0)
        {
            let createCell = collectionView.dequeueReusableCell(withReuseIdentifier: "createSquadCell", for: indexPath)
            return createCell
        }
        else if((indexPath as NSIndexPath).row == 1)
        {
            let joinCell = collectionView.dequeueReusableCell(withReuseIdentifier: "joinSquadCell", for: indexPath)
            return joinCell
        }
        else
        {
            let cVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cVCell", for: indexPath) as! SquadCollectionViewCell
            
            // Configure the cell
            let squad = SquadCore.theSquads[(indexPath as NSIndexPath).row-2]
            
            cVCell.nameLabel.text = squad["name"] as? String
            let sport = squad["sport"] as! PFObject
            sport.fetchInBackground(block: { (obj: PFObject?, error: Error?) in
                
                cVCell.sportLabel.text = sport["name"] as? String
            })
            
            cVCell.layer.cornerRadius = 5
            SquadCore.getImage(iv: cVCell.teamImage, imageName: squad["imageName"] as! String, profileImage: false)
            return cVCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if((indexPath as NSIndexPath).row == 0)
        {
            //do create squad stuff
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateSquadNavController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        }
        else if((indexPath as NSIndexPath).row == 1)
        {
            //do join squad stuff
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "JoinSquadVC") as! JoinSquadVC
            self.present(vc, animated: true, completion: nil)
        }
        else
        {
            //instantiate load screen
            let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: "LoadingVC")
            
            //position it relative to the current view
            let newX = (self.view.frame.size.width/2) - 50
            let newY = (self.view.frame.size.height/2) - 50
            loadingVC!.view.frame = CGRect(x: newX, y: newY, width: 300, height: 300)
            
            //place it on the screen using the main queue
            self.view.addSubview(loadingVC!.view)
            
            //wrap anything that is slow loading in a dispatch_async on global queue (NOT MAIN QUEUE)
            DispatchQueue.global().async 
            {
                SquadCore.selectedSquad = SquadCore.theSquads[(indexPath as NSIndexPath).row-2]
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
                
                let cell = collectionView.cellForItem(at: indexPath) as! SquadCollectionViewCell
                SquadCore.currTeamImage = cell.teamImage
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SquadTabBarController") as! UITabBarController
                self.present(vc, animated: false, completion: nil)
                
                //at the very end after the loading is done, make the load screen go away using the mainQueue
                DispatchQueue.main.async(execute: {
                    loadingVC!.view.removeFromSuperview()
                    self.view.setNeedsDisplay()
                })
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
