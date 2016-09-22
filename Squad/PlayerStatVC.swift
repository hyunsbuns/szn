//
//  PlayerStatVC.swift
//  Squad
//
//  Created by Michael Litman on 12/29/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse

class PlayerStatVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    var statsToDisplay = [PFObject]()
    var tempStatCollection : StatCollection? = nil
    var player : PFObject!
    var collection : StatCollection!
    var parentGameStatsVC : GameStatsVC!
    
    @IBOutlet weak var attendedSwitch: UISwitch!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //filter the stats for non-calculated stats
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat.value(forKey: "calculated") as! Bool))
            {
                self.statsToDisplay.append(stat)
            }
        }
        
        //should did attend swich be on or off?
        self.attendedSwitch.isOn = self.collection.didAttend()
        if(player["user"] == nil)
        {
            let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
            navBar.topItem?.title = "\(name)"
        }
        else
        {
            let user = player["user"] as! PFUser
            let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
            navBar.topItem?.title = "\(name)"
        }
        self.view.backgroundColor = skwadDarkGrey
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        self.parentGameStatsVC.rosterCollectionView.reloadData()
    }
    
    func toggleDidAttendSwitch()
    {
        if attendedSwitch.isOn
        {
            self.collection.setDidAttend(true)
        }
        else
        {
            self.collection.setDidAttend(false)
            for stat in self.statsToDisplay
            {
                self.collection.setStat(stat["name"] as! String, value: 0.0)
            }
            self.theCollectionView.reloadData()
        }
    }
    
    @IBAction func attendedSwitchTapped(_ sender: AnyObject)
    {
        SquadCore.setStatRefresh()
        self.toggleDidAttendSwitch()
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject)
    {
        //save any changed stats to parse and update previous screen
        self.collection.save()
        self.parentGameStatsVC.rosterCollectionView.reloadData()
        //Summary table view will autoreload in viewWillAppear of prev screen to update totals
        self.dismiss(animated: true, completion: nil )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.statsToDisplay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StatCollectionCell
    
        cell.collection = self.collection
        cell.statName.text = self.statsToDisplay[(indexPath as NSIndexPath).row].value(forKey: "name") as? String
        cell.parentPlayerStatVC = self
        
        //set current stats
        let statCollection = self.collection
        var value = 0.0
        if(statCollection != nil)
        {
            let statName = self.statsToDisplay[(indexPath as NSIndexPath).row].value(forKey: "name") as! String
            value = statCollection!.getStatValue(statName)
        }
        cell.countLabel.text = "\(Int(value))"
        cell.count = value
        return cell
    }
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
