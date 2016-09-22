//
//  GameStatsVC.swift
//  Squad
//
//  Created by Steve on 12/22/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import Spring
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameStatsVC: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    var scoreArray = [Int](0...200)
    var gameStatsScrollGrid : StatScrollGridVC!
    var gameStatsSummaryController : GameStatsSummaryTVC!
    
    var dynamicHeight = CGFloat(SquadCore.selectedSquadRoster.count) * 20
    
    var eventData = [StatCollection?]()
    var featuredStats : [String]!
    var origScore = [String: Int]()
    
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rosterCollectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var winLossLabel: SpringLabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var mySquadNameLabel: UILabel!
    @IBOutlet weak var opponentScoreTF: TextField!
    @IBOutlet weak var squadScoreTF: TextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = asphaltColor
        
        //set the featured stats
        let sport = SquadCore.selectedSquad["sport"] as! PFObject
        let fs = sport["featured_stats"] as! String
        self.featuredStats = fs.components(separatedBy: ",")
        
        //try! sport.fetch()
        //hit parse and get real data
        SquadCore.currentStatTotals = SquadCore.getLeaders(SquadCore.currentActiveSeason, roster: SquadCore.selectedSquadRoster)
        
        for player in SquadCore.selectedSquadRoster
        {
            let total = SquadCore.getStatTotalGivenPlayer(player, statTotals: SquadCore.currentStatTotals)
            let collection = total?.getCollectionForEvent(SquadCore.selectedEvent)
            eventData.append(collection!)
        }
        //Now eventData has all of my data I need for this screen
        
        //get the current score of this game
        SquadCore.gameStatsEventScore = SquadCore.getCurrentScore(SquadCore.selectedEvent)
        self.origScore["home"] = SquadCore.gameStatsEventScore.value(forKey: "score") as? Int
        self.origScore["opponent"] = SquadCore.gameStatsEventScore.value(forKey: "opponent_score") as? Int
        
        self.squadScoreTF.text = "\(SquadCore.gameStatsEventScore.value(forKey: "score") as! Int)"
        self.opponentScoreTF.text = "\(SquadCore.gameStatsEventScore.value(forKey: "opponent_score") as! Int)"
        
        //self.containerView!.frame = CGRectMake(0, 0, self.view.frame.width, dynamicHeight)
        
        //disable score editing if READ_ONLY
        if(SquadCore.currentSeasonSelectorDelegate.READ_ONLY)
        {
            self.squadScoreTF.isEnabled = false
            self.opponentScoreTF.isEnabled = false
        }
        else
        {
            if(SquadCore.isAdmin(SquadCore.selectedSquad, user: SquadCore.currentUser))
            {
                self.squadScoreTF.isEnabled = true
                self.opponentScoreTF.isEnabled = true
            }
            else
            {
                self.squadScoreTF.isEnabled = false
                self.opponentScoreTF.isEnabled = false
            }
        }
        
        self.view.layoutIfNeeded()
        //self.view.backgroundColor = skwadDarkGrey
        opponentScoreTF.attributedPlaceholder = NSAttributedString(string:"0",
            attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        squadScoreTF.attributedPlaceholder = NSAttributedString(string:"0",
            attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        opponentNameLabel.text = "\(SquadCore.selectedEvent.object(forKey: "opponent_name") as! String)".uppercased()
        mySquadNameLabel.text = "\(SquadCore.selectedSquad.value(forKey: "name") as! String)".uppercased()
        
        winLossLabel.layer.backgroundColor = aquaColor.cgColor
        winLossLabel.text = "T"
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        let pickerView2 = UIPickerView()
        pickerView2.delegate = self
        pickerView2.tag = 2
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.black
        toolBar.backgroundColor = UIColor.black
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(GameStatsVC.donePressed(_:)))
        toolBar.setItems([flexSpace, doneButton], animated: true)
        
        opponentScoreTF.inputAccessoryView = toolBar
        squadScoreTF.inputAccessoryView = toolBar
        
        
        opponentScoreTF.inputView = pickerView
        squadScoreTF.inputView = pickerView2
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.fillPlayerTotals()
        //self.rosterCollectionView.reloadData()
        
        if opponentScore == squadScore {
            
            self.winLossLabel.text = "T"
            
        }
        else if opponentScore > squadScore {
            
            self.winLossLabel.text = "L"
            
            
        }
        else {
            
            self.winLossLabel.text = "W"

        }
    }
    
    func getCollectionForPlayer(_ player: PFObject) -> StatCollection?
    {
        var pos = 0
        for p in SquadCore.selectedSquadRoster
        {
            if(player.objectId! == p.objectId!)
            {
                return self.eventData[pos]
            }
            pos += 1
        }
        return nil
    }
    
    @IBAction func squadScoreAdded(_ sender: AnyObject)
    {
        winLossUpdate()
    }
    
    @IBAction func opponentScoreChanged(_ sender: AnyObject)
    {
        winLossUpdate()
    }
    
    //These actions are here to disable copy/paste and cursor on textfields
    
    @IBAction func opponentScoreEditing(_ sender: TextField)
    {
    }
    
    
    @IBAction func squadScoreEditing(_ sender: TextField)
    {
    }
    
    
    var opponentScore: Int?
    {
        return Int(opponentScoreTF.text!)
    }
    
    var squadScore: Int?
    {
        return Int(squadScoreTF.text!)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject)
    {
        let opponentScore = Int(opponentScoreTF.text!)!
        let score = Int(squadScoreTF.text!)!
        if(score != self.origScore["home"]! || opponentScore != self.origScore["opponent"]!)
        {
            SquadCore.updateScore(score , opponent_score: opponentScore)
            SquadCore.FoldScheduleVC_TableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil )
    }

    func roundToDecimalPlaces(_ value: CGFloat, places: Int = 2) -> CGFloat
    {
        let multiplier = CGFloat(10^places)
        return round(multiplier * value) / multiplier
    }
    
    func formatNumber(_ value : CGFloat) -> String
    {
        let valueString = "\(value)"
        if(valueString.characters.count > 4)
        {
            return (valueString as NSString).substring(to: 4)
        }
        else
        {
            return valueString
        }
    }

    
    func fillPlayerTotals()
    {
        self.gameStatsScrollGrid.reset()
        self.gameStatsScrollGrid.addPlayerHeader("PLAYER NAME")
        
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                let user = player["user"] as! PFUser
                //try! user.fetchIfNeeded()
                let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
                self.gameStatsScrollGrid.addPlayerName(name)
            }
            else
            {
                let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
                self.gameStatsScrollGrid.addPlayerName(name)
            }
        }
        
        self.gameStatsScrollGrid.addPlayerFooter("Totals")
        
        for stat in SquadCore.selectedSquadStats
        {
            let statName = stat.value(forKey: "short_name") as! String
            self.gameStatsScrollGrid.addStatHeader(statName)
        }
        self.gameStatsScrollGrid.statMoveToNextRow()
        
        //set the total data
        var totalsArrays = [String:Double]()
        for stat in SquadCore.selectedSquadStats
        {
            if(stat["calculated"] as! Bool)
            {
                totalsArrays[stat.value(forKey: "name") as! String] = 0.0
            }
            else
            {
                totalsArrays[stat.value(forKey: "name") as! String] = 0
            }
        }
        
        for player in SquadCore.selectedSquadRoster
        {
            let totals = SquadCore.getStatTotalGivenPlayer(player, statTotals: SquadCore.currentStatTotals)!
            let collection = totals.getCollectionForEvent(SquadCore.selectedEvent)
            //let collection = self.getCollectionForPlayer(player)
            for stat in SquadCore.selectedSquadStats
            {
                let statName = stat.value(forKey: "name") as! String
                var value = 0.0
                if(collection != nil)
                {
                    value = collection!.getStatValue(statName)
                }
                if(stat["calculated"] as! Bool)
                {
                    if(value < 1 && value != 0.0)
                    {
                        let s = String(format:"%.3f", value)
                        self.gameStatsScrollGrid.addStatTotal(s.substring(from: s.characters.index(after: s.startIndex)))
                    }
                    else
                    {
                        let s = String(format:"%.1f", value)
                        self.gameStatsScrollGrid.addStatTotal(s)
                    }
                    
                    totalsArrays[stat.value(forKey: "name") as! String] = totalsArrays[stat.value(forKey: "name") as! String]! + value
                }
                else
                {
                    self.gameStatsScrollGrid.addStatTotal("\(Int(value))")
                    totalsArrays[stat.value(forKey: "name") as! String] = totalsArrays[stat.value(forKey: "name") as! String]! + value

                }
            }
            self.gameStatsScrollGrid.statMoveToNextRow()
        }
        
        //set the totals
        for stat in SquadCore.selectedSquadStats
        {
            if(stat["calculated"] as! Bool)
            {
                let total = totalsArrays[stat.value(forKey: "name") as! String]!
            
                let totalAvg = total/Double(SquadCore.selectedSquadRoster.count)
                
                if(totalAvg < 1 && totalAvg != 0.0)
                {
                    let s = String(format:"%.3f", totalAvg)
                    self.gameStatsScrollGrid.addStatTotal(s.substring(from: s.characters.index(after: s.startIndex)))
                }
                else
                {
                    let s = String(format:"%.1f", totalAvg)
                    self.gameStatsScrollGrid.addStatTotal(s)
                }
            }
            else
            {
                let total = totalsArrays[stat.value(forKey: "name") as! String]!
                self.gameStatsScrollGrid.addStatTotal("\(Int(total))")
            }
        }
        
        let cs = self.scrollView.contentSize
        self.scrollView.contentSize = CGSize(width: cs.width, height: self.gameStatsScrollGrid.getHeight() + 394)
    }

    func donePressed(_ sender: UIBarButtonItem) {
        
        opponentScoreTF.resignFirstResponder()
        squadScoreTF.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return scoreArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(scoreArray[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.tag == 2
        {
            squadScoreTF.text = String(scoreArray[row])
        }
        else
        {
            opponentScoreTF.text = String(scoreArray[row])
        }
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool
    {
        opponentScoreTF.resignFirstResponder()
        squadScoreTF.resignFirstResponder()
        return true
    }
    
    func winLossUpdate()
    {
        
        if opponentScore == squadScore {

                self.winLossLabel.text = "T"
                self.winLossLabel.animation = "flipX"
                self.winLossLabel.animate()
               
            
        }
        else if opponentScore > squadScore {
            
                self.winLossLabel.text = "L"
                self.winLossLabel.animation = "flipX"
                self.winLossLabel.animate()
            
        }
        else {
            
                self.winLossLabel.text = "W"
                self.winLossLabel.animation = "flipX"
                self.winLossLabel.animate()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return SquadCore.selectedSquadRoster.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RosterCollectionCell
        let player = SquadCore.selectedSquadRoster[(indexPath as NSIndexPath).row]
        if(player["user"] != nil)
        {
            let user = player["user"] as! PFUser
            user.fetchIfNeededInBackground(block: { (obj: PFObject?, error: Error?) in
                let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
                
                cell.playerName.text = name
                let imageName = user["imageName"]
                if(imageName != nil)
                {
                    SquadCore.getImage(iv: cell.playerImage, imageName: imageName as! String, profileImage: true)
                }

            })
        }
        else
        {
            let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
            
            cell.playerName.text = name
            let imageName = player["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: cell.playerImage, imageName: imageName as! String, profileImage: true)
            }
        }
        
        let number = player["jersey_number"]
        if(number != nil)
        {
            cell.jerseyNumberLabel.text = number as? String
        }
        else
        {
            cell.jerseyNumberLabel.text = ""
        }
        
        
        
        //cell.playerImage.file = SquadCore.selectedSquadRoster[indexPath.row].valueForKey("profilePhoto") as? PFFile
        //cell.playerImage.loadInBackground()
        
        let collection = self.getCollectionForPlayer(player)
        
        //set the featured stats
        cell.featured_stat1_name.text = self.featuredStats[0]
        cell.featured_stat2_name.text = self.featuredStats[1]
        cell.featured_stat3_name.text = self.featuredStats[2]
        cell.featured_stat4_name.text = self.featuredStats[3]
        cell.featured_stat1_value.text = "\(Int(collection!.getShortStatValue(self.featuredStats[0])))"
        cell.featured_stat2_value.text = "\(Int(collection!.getShortStatValue(self.featuredStats[1])))"
        cell.featured_stat3_value.text = "\(Int(collection!.getShortStatValue(self.featuredStats[2])))"
        cell.featured_stat4_value.text = "\(Int(collection!.getShortStatValue(self.featuredStats[3])))"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //only let stats be edited if it is NOT READ ONLY
        if(!SquadCore.currentSeasonSelectorDelegate.READ_ONLY && SquadCore.isAdmin(SquadCore.selectedSquad, user: SquadCore.currentUser))
        {
            let player = SquadCore.selectedSquadRoster[(indexPath as NSIndexPath).row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerStatVC") as! PlayerStatVC
            vc.parentGameStatsVC = self
            vc.player = player
            vc.collection = self.getCollectionForPlayer(player)
            self.present(vc, animated: true, completion: nil)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier != nil && segue.identifier! == "GameStatsScroll")
        {
            self.gameStatsScrollGrid = segue.destination as! StatScrollGridVC
        }
    }
    

}
