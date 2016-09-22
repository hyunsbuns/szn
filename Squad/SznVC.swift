//
//  SznVC.swift
//  Squad
//
//  Created by Steve on 1/12/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse
import Spring

let photoBlue: UIColor = UIColor( red: CGFloat(63/255.0), green: CGFloat(166/255.0), blue: CGFloat(252/255.0), alpha: CGFloat(100.0) )

let darkblue: UIColor = UIColor( red: CGFloat(11/255.0), green: CGFloat(137/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(100.0) )

let darkestBlue: UIColor = UIColor( red: CGFloat(13/255.0), green: CGFloat(96/255.0), blue: CGFloat(173/255.0), alpha: CGFloat(100.0) )

class SznVC: UIViewController, UIPopoverPresentationControllerDelegate,  SeasonSelectorDelegate
{
    var currentSeason : PFObject!
    var seasonChanged = false
    var READ_ONLY = false
    var premiumRequiredVC : PremiumRequiredVC!
    
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var seasonLeadersCurrentStatLabel: UILabel!
    @IBOutlet weak var seasonLeadersPrevStatButton: UIButton!
    @IBOutlet weak var seasonLeadersNextStatButton: UIButton!
    var seasonLeadersCurrStatPos = 0
    
    @IBOutlet weak var seasonLeadersStack: UIStackView!
    @IBOutlet weak var seasonAveragesStack: UIStackView!
    @IBOutlet weak var seasonTotalsStack: UIStackView!

    @IBOutlet weak var seasonTotalsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seasonLeadersContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var seasonAveragesContainer: UIView!
    @IBOutlet weak var seasonTotalsContainer: UIView!
    @IBOutlet weak var seasonAveragesContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var leadersBarButton: UIBarButtonItem!
    @IBOutlet weak var statsBarButton: UIBarButtonItem!
    @IBOutlet weak var mainStack: UIStackView!

    var seasonLeadersController : SeasonLeadersTVC!
    var careerVC : CareerVC!
    
    var mode = "Season"
    var seasonLeaderCollectionSelectedIndex = 0
    var seasonAveragesScrollGrid : StatScrollGridVC!
    var seasonTotalsScrollGrid : StatScrollGridVC!
    var currentStatTotals = SquadCore.currentStatTotals
    
    var currToggle = ""
    var shouldLayoutConstraints = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.careerVC = self.storyboard?.instantiateViewController(withIdentifier: "CareerVC") as! CareerVC
        
        self.premiumRequiredVC = self.storyboard?.instantiateViewController(withIdentifier: "PremiumRequiredVC") as! PremiumRequiredVC
         self.premiumRequiredVC.navBarTitleText = "Stats"
        
        //Set the current active season when this screen first loads
        self.currentSeason = SquadCore.currentActiveSeason
        self.currentStatTotals = SquadCore.currentStatTotals
        //need this in view will appear and here just in case
        SquadCore.currentSeasonSelectorDelegate = self
        self.setSeasonLabel()
        
        self.seasonLeadersUpdateStat()
        self.seasonTotalsStack.isHidden = false
        self.seasonAveragesStack.isHidden = false
        self.seasonLeadersStack.isHidden = true
        self.currToggle = "Stats"
        self.setBarButtonColors()
        
        self.statsBarButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!], for: UIControlState())
        self.statsBarButton.tintColor = UIColor.white
        
        self.leadersBarButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!], for: UIControlState())
        self.leadersBarButton.tintColor = UIColor.lightGray
        
        //navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "PlanetExpressItalic", size: 22)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        
        
        //self.view.backgroundColor = asphaltColor
        self.toolBar.layer.backgroundColor = asphaltColor.cgColor
        
    }

    @IBAction func careerButtonPressed()
    {
        self.present(self.careerVC, animated: false, completion: nil)
    }
    
    @IBAction func seasonLeadersPrevStatButtonPressed()
    {
        self.seasonLeadersCurrStatPos -= 1
        self.seasonLeadersUpdateStat()
    }
    
    @IBAction func seasonLeadersNextStatButtonPressed()
    {
        self.seasonLeadersCurrStatPos += 1
        self.seasonLeadersUpdateStat()
    }

    func seasonLeadersUpdateStat()
    {
        self.seasonLeadersCurrentStatLabel.text = SquadCore.selectedSquadStats[self.seasonLeadersCurrStatPos]["name"] as? String
        self.seasonLeadersPrevStatButton.alpha = 1
        self.seasonLeadersNextStatButton.alpha = 1
        if(self.seasonLeadersCurrStatPos == 0)
        {
            self.seasonLeadersPrevStatButton.alpha = 0
        }
        
        if(self.seasonLeadersCurrStatPos == SquadCore.selectedSquadStats.count-1)
        {
            self.seasonLeadersNextStatButton.alpha = 0
        }
        
        self.seasonLeaderCollectionSelectedIndex = self.seasonLeadersCurrStatPos
        self.seasonLeadersController.setStat(SquadCore.selectedSquadStats[self.seasonLeadersCurrStatPos].value(forKey: "name") as! String)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if(!SquadCore.premiumEnabled)
        {
            self.view.addSubview(self.premiumRequiredVC.view)
        }
        else
        {
            self.premiumRequiredVC.view.removeFromSuperview()
        }
        
        //If this is true, we had already dealt with part of it in the segue
        //this is the other half since the scrollview was not in existance yet
        
        //need this in view did load and here just in case
        SquadCore.currentSeasonSelectorDelegate = self
        
        if(SquadCore.sznstats_ReloadStats)
        {
            self.currentStatTotals = SquadCore.getLeaders(self.currentSeason, roster: SquadCore.selectedSquadRoster)
            SquadCore.sznstats_ReloadStats = false
            self.seasonLeadersController.seasonTotals = self.currentStatTotals!
            self.seasonLeadersController.refreshData()
        }
        self.fillPlayerAverages()
        self.fillPlayerTotals()
        // + self.seasonLeadersContainerHeightConstraint.constant
        
        self.seasonLeadersContainerHeightConstraint.constant = self.seasonLeadersController.getHeight()
        self.seasonAveragesContainerHeightConstraint.constant = self.seasonAveragesScrollGrid.getHeight()
        self.seasonTotalsContainerHeightConstraint.constant = self.seasonTotalsScrollGrid.getHeight()
        self.theScrollView.contentSize = CGSize(width: self.theScrollView.contentSize.width, height: self.seasonAveragesContainerHeightConstraint.constant + self.seasonTotalsContainerHeightConstraint.constant+88)
        
        // Need to call this line to force constraint updated
        self.view.layoutSubviews()
        
    }
    
    func setBarButtonColors() {
        if(self.currToggle == "Stats")
        {
            self.statsBarButton.tintColor = goldColor
            self.leadersBarButton.tintColor = UIColor.darkGray
            
        }
        else if(self.currToggle == "Leaders")
        {
            self.statsBarButton.tintColor = UIColor.darkGray
            self.leadersBarButton.tintColor = goldColor
        }
    }
    
    @IBAction func toggleButtonPressed(_ sender: UIBarButtonItem)
    {
        if(sender == self.statsBarButton)
        {
            //self.seasonAveragesContainer.hidden = false
            //self.seasonTotalsContainer.hidden = false
            //self.seasonLeadersStack.hidden = true
            self.seasonTotalsStack.isHidden = false
            self.seasonAveragesStack.isHidden = false
            self.seasonLeadersStack.isHidden = true
            self.theScrollView.contentSize = CGSize(width: self.theScrollView.contentSize.width, height: self.seasonAveragesContainerHeightConstraint.constant + self.seasonTotalsContainerHeightConstraint.constant+70)
            self.currToggle = "Stats"
            
        }
        else if(sender == self.leadersBarButton)
        {
            //self.seasonAveragesContainer.hidden = true
            //self.seasonTotalsContainer.hidden = true
            //self.seasonLeadersStack.hidden = false
            self.seasonTotalsStack.isHidden = true
            self.seasonAveragesStack.isHidden = true
            self.seasonLeadersStack.isHidden = false
            self.theScrollView.contentSize = CGSize(width: self.theScrollView.contentSize.width, height: self.seasonAveragesContainerHeightConstraint.constant + self.seasonTotalsContainerHeightConstraint.constant-70)
            self.currToggle = "Leaders"
        }
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
    
    func fillPlayerAverages()
    {
        self.seasonAveragesScrollGrid.reset()
        self.seasonAveragesScrollGrid.addPlayerHeader("Player Name")
        
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                let user = player["user"] as! PFUser
                let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
                self.seasonAveragesScrollGrid.addPlayerName(name)
            }
            else
            {
                let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
                self.seasonAveragesScrollGrid.addPlayerName(name)
            }
        }
        
        self.seasonAveragesScrollGrid.addPlayerFooter("Totals")
        
        for stat in SquadCore.selectedSquadStats
        {
            let statName = stat.value(forKey: "short_name") as! String
            self.seasonAveragesScrollGrid.addStatHeader(statName)
        }
        self.seasonAveragesScrollGrid.statMoveToNextRow()
        
        //set the average data
        var totalsArrays = [String:Double]()
        for stat in SquadCore.selectedSquadStats
        {
            totalsArrays[stat.value(forKey: "name") as! String] = 0.0
        }

        if(self.seasonChanged)
        {
            self.currentStatTotals = SquadCore.getLeaders(self.currentSeason, roster: SquadCore.selectedSquadRoster)
            self.seasonChanged = false
        }
        
        for player in SquadCore.selectedSquadRoster
        {
            let totals = SquadCore.getStatTotalGivenPlayer(player, statTotals: self.currentStatTotals!)!
            
            for stat in SquadCore.selectedSquadStats
            {
                let statName = stat.value(forKey: "name") as! String
                let value = totals.getAverageForStat(statName)
                if(value < 1 && value != 0)
                {
                    let s = String(format:"%.3f", value)
                    self.seasonAveragesScrollGrid.addStatTotal(s.substring(from: s.characters.index(after: s.startIndex)))
                }
                else
                {
                    self.seasonAveragesScrollGrid.addStatTotal(String(format:"%.1f", value))
                }
                
                totalsArrays[stat.value(forKey: "name") as! String] = totalsArrays[stat.value(forKey: "name") as! String]! + value
            }
            self.seasonAveragesScrollGrid.statMoveToNextRow()
        }
        
        //set the average totals
        let rosterSize = Double(SquadCore.selectedSquadRoster.count)
        for stat in SquadCore.selectedSquadStats
        {
            let averageTotal = totalsArrays[stat.value(forKey: "name") as! String]! / rosterSize
            if(averageTotal < 1 && averageTotal != 0)
            {
                let s = String(format:"%.3f", averageTotal)
                self.seasonAveragesScrollGrid.addStatTotal(s.substring(from: s.characters.index(after: s.startIndex)))
            }
            else
            {
                self.seasonAveragesScrollGrid.addStatTotal(String(format:"%.1f", averageTotal))
            }
/*
            if(averageTotal < 1)
            {
                //for things like batting averages
                let averageTotalString = "\(averageTotal)"
                if(averageTotalString.characters.count > 4)
                {
                    let roundedTotal = self.roundToDecimalPlaces(CGFloat(averageTotal), places: 3)
                    self.seasonAveragesScrollGrid.addStatTotal(self.formatNumber(CGFloat(roundedTotal)))
                }
                else
                {
                    self.seasonAveragesScrollGrid.addStatTotal(averageTotalString)
                }
            }
            else
            {
                let roundedTotal = self.roundToDecimalPlaces(CGFloat(averageTotal), places: 1)
                self.seasonAveragesScrollGrid.addStatTotal(self.formatNumber(CGFloat(roundedTotal)))
            }
 */
        }
    }
    
    func fillPlayerTotals()
    {
        self.seasonTotalsScrollGrid.reset()
        self.seasonTotalsScrollGrid.addPlayerHeader("Player Name")
        
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                let user = player["user"] as! PFUser
                //try! user.fetchIfNeeded()
                let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
                self.seasonTotalsScrollGrid.addPlayerName(name)
            }
            else
            {
                let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
                self.seasonTotalsScrollGrid.addPlayerName(name)

            }
        }
        
        self.seasonTotalsScrollGrid.addPlayerFooter("Totals")
        
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat["calculated"] as! Bool))
            {
                let statName = stat.value(forKey: "short_name") as! String
                self.seasonTotalsScrollGrid.addStatHeader(statName)
            }
        }
        self.seasonTotalsScrollGrid.statMoveToNextRow()
        
        //set the total data
        var totalsArrays = [String:Double]()
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat["calculated"] as! Bool))
            {
                totalsArrays[stat.value(forKey: "name") as! String] = 0.0
            }
        }
        
        if(self.seasonChanged)
        {
            self.currentStatTotals = SquadCore.getLeaders(self.currentSeason, roster: SquadCore.selectedSquadRoster)
            self.seasonChanged = false
        }
        
        for player in SquadCore.selectedSquadRoster
        {
            let totals = SquadCore.getStatTotalGivenPlayer(player, statTotals: self.currentStatTotals!)!
            for stat in SquadCore.selectedSquadStats
            {
                if(!(stat["calculated"] as! Bool))
                {
                    let statName = stat.value(forKey: "name") as! String
                    let value = totals.getTotalForStat(statName)
                    if(value.isNaN)
                    {
                        self.seasonTotalsScrollGrid.addStatTotal("N/A")
                    }
                    else
                    {
                        self.seasonTotalsScrollGrid.addStatTotal("\(Int(value))")
                        totalsArrays[statName] = totalsArrays[statName]! + value
                    }
                }
            }
            self.seasonTotalsScrollGrid.statMoveToNextRow()
        }
        
        //set the totals
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat["calculated"] as! Bool))
            {
                let total = totalsArrays[stat.value(forKey: "name") as! String]!
                if(total.isNaN)
                {
                    self.seasonTotalsScrollGrid.addStatTotal("N/A")
                }
                else
                {
                    self.seasonTotalsScrollGrid.addStatTotal("\(Int(total))")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return SquadCore.selectedSquadStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statCell", for: indexPath) as! SeasonStatMenuCollectionCell
        var shortName = SquadCore.selectedSquadStats[(indexPath as NSIndexPath).row].value(forKey: "short_name") as! String
        if(shortName.length == 1)
        {
            shortName = "    \(shortName)    "
        }
        else if(shortName.length == 2)
        {
            shortName = "  \(shortName)  "
        }
        cell.label.text = shortName
        cell.label.font = UIFont.boldSystemFont(ofSize: 16)
        if(self.seasonLeaderCollectionSelectedIndex == (indexPath as NSIndexPath).row)
        {
            cell.label.textColor = goldColor
            cell.lineUnder.isHidden = false
        }
        else
        {
            cell.label.textColor = UIColor.lightGray
            cell.lineUnder.isHidden = true
        }
        
        if cell.label.textColor == skwadDarkGrey {
            cell.label.animation = "pop"
            cell.label.animate()
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath)
    {
        self.seasonLeaderCollectionSelectedIndex = (indexPath as NSIndexPath).row
        self.seasonLeadersController.setStat(SquadCore.selectedSquadStats[(indexPath as NSIndexPath).row].value(forKey: "name") as! String)
        collectionView.reloadData()
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

    //SeasonSelectorDelegate Methods
    func updateActiveInterfaceElements()
    {
    }

    func setSeasonLabel()
    {
        self.seasonLabel.text = self.currentSeason.value(forKey: "name") as? String
        self.seasonChanged = true
        self.fillPlayerTotals()
        self.fillPlayerAverages()
        self.seasonLeadersController.seasonTotals = self.currentStatTotals!
        self.seasonLeadersController.refreshData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(SquadCore.sznstats_ReloadStats)
        {
            SquadCore.currentStatTotals = SquadCore.getLeaders(SquadCore.currentActiveSeason, roster: SquadCore.selectedSquadRoster)
            SquadCore.sznstats_ReloadStats = false
        }

        if(segue.identifier != nil && segue.identifier! == "EmbeddedSeasonLeadersTVC")
        {
            self.seasonLeadersController = segue.destination as! SeasonLeadersTVC
            self.seasonLeadersController.currStat = SquadCore.selectedSquadStats[0].value(forKey: "name") as! String
            self.seasonLeadersController.currSeason = SquadCore.currentActiveSeason
            self.seasonLeadersController.seasonTotals = SquadCore.currentStatTotals
            self.seasonLeadersController.refreshData()
        }
        else if(segue.identifier != nil && segue.identifier! == "SeasonTotalsEmbed")
        {
            self.seasonTotalsScrollGrid = segue.destination as! StatScrollGridVC
        }
        else if(segue.identifier != nil && segue.identifier! == "SeasonAveragesEmbed")
        {
            self.seasonAveragesScrollGrid = segue.destination as! StatScrollGridVC
        }
        else if(segue.identifier != nil && segue.identifier! == "SeasonPopover")
        {
            let popPC = segue.destination.popoverPresentationController
            popPC!.delegate = self;
        }

    }
}
