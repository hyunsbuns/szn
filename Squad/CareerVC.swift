//
//  CareerVC.swift
//  Squad
//
//  Created by Michael Litman on 8/3/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse
import Spring

class CareerVC: UIViewController
{
    let photoBlue: UIColor = UIColor( red: CGFloat(63/255.0), green: CGFloat(166/255.0), blue: CGFloat(252/255.0), alpha: CGFloat(100.0) )
    
    let darkblue: UIColor = UIColor( red: CGFloat(11/255.0), green: CGFloat(137/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(100.0) )
    
    let darkestBlue: UIColor = UIColor( red: CGFloat(13/255.0), green: CGFloat(96/255.0), blue: CGFloat(173/255.0), alpha: CGFloat(100.0) )

    @IBOutlet weak var careerLeadersCurrentStatLabel: UILabel!
    @IBOutlet weak var careerLeadersPrevStatButton: UIButton!
    @IBOutlet weak var careerLeadersNextStatButton: UIButton!
    var careerLeadersCurrStatPos = 0
    
    @IBOutlet weak var careerLeadersStack: UIStackView!
    @IBOutlet weak var careerAveragesStack: UIStackView!
    @IBOutlet weak var careerTotalsStack: UIStackView!
    
    @IBOutlet weak var careerTotalsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var careerLeadersContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var careerAveragesContainer: UIView!
    @IBOutlet weak var careerTotalsContainer: UIView!
    @IBOutlet weak var careerAveragesContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var leadersBarButton: UIBarButtonItem!
    @IBOutlet weak var statsBarButton: UIBarButtonItem!
    @IBOutlet weak var mainStack: UIStackView!

    var careerLeadersController : CareerLeadersTVC!
    var careerAveragesScrollGrid : StatScrollGridVC!
    var careerTotalsScrollGrid : StatScrollGridVC!
    var careerLeaderCollectionSelectedIndex = 0
    var currToggle = ""
    var currentStatTotals = SquadCore.getCareerLeaders(SquadCore.selectedSquadRoster)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.careerTotalsStack.isHidden = false
        self.careerAveragesStack.isHidden = false
        self.careerLeadersStack.isHidden = true
        self.currToggle = "Stats"
        self.setBarButtonColors()
        
        self.statsBarButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 16)!], for: UIControlState())
        self.statsBarButton.tintColor = UIColor.white
        
        self.leadersBarButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 16)!], for: UIControlState())
        self.leadersBarButton.tintColor = UIColor.lightGray
        self.careerLeadersUpdateStat()
        
        //navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "PlanetExpressItalic", size: 22)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        
        
        self.view.backgroundColor = asphaltColor
        self.toolBar.layer.backgroundColor = asphaltColor.cgColor
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        self.fillPlayerAverages()
        self.fillPlayerTotals()
        self.careerLeadersContainerHeightConstraint.constant = self.careerLeadersController.getHeight()
        self.careerAveragesContainerHeightConstraint.constant = self.careerAveragesScrollGrid.getHeight()
        self.careerTotalsContainerHeightConstraint.constant = self.careerTotalsScrollGrid.getHeight()
        self.theScrollView.contentSize = CGSize(width: self.theScrollView.contentSize.width, height: self.careerAveragesContainerHeightConstraint.constant + self.careerTotalsContainerHeightConstraint.constant + 75)
    }
    
    func fillPlayerAverages()
    {
        self.careerAveragesScrollGrid.reset()
        self.careerAveragesScrollGrid.addPlayerHeader("Player Name")
        
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                let user = player["user"] as! PFUser
                let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
                self.careerAveragesScrollGrid.addPlayerName(name)
            }
            else
            {
                let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
                self.careerAveragesScrollGrid.addPlayerName(name)
            }
        }
        
        self.careerAveragesScrollGrid.addPlayerFooter("Totals")
        
        for stat in SquadCore.selectedSquadStats
        {
            let statName = stat.value(forKey: "short_name") as! String
            self.careerAveragesScrollGrid.addStatHeader(statName)
        }
        self.careerAveragesScrollGrid.statMoveToNextRow()
        
        //set the average data
        var totalsArrays = [String:Double]()
        for stat in SquadCore.selectedSquadStats
        {
            totalsArrays[stat.value(forKey: "name") as! String] = 0.0
        }
        
        for player in SquadCore.selectedSquadRoster
        {
            let totals = SquadCore.getStatTotalGivenPlayer(player, statTotals: self.currentStatTotals)!
            
            for stat in SquadCore.selectedSquadStats
            {
                let statName = stat.value(forKey: "name") as! String
                let value = totals.getAverageForStat(statName)
                if(value < 1 && value != 0)
                {
                    let s = String(format:"%.3f", value)
                    self.careerAveragesScrollGrid.addStatTotal(s.substring(from: s.characters.index(after: s.startIndex)))
                }
                else
                {
                    self.careerAveragesScrollGrid.addStatTotal(String(format:"%.1f", value))
                }
                
                totalsArrays[stat.value(forKey: "name") as! String] = totalsArrays[stat.value(forKey: "name") as! String]! + value
            }
            self.careerAveragesScrollGrid.statMoveToNextRow()
        }
        
        //set the average totals
        let rosterSize = Double(SquadCore.selectedSquadRoster.count)
        for stat in SquadCore.selectedSquadStats
        {
            let averageTotal = totalsArrays[stat.value(forKey: "name") as! String]! / rosterSize
            if(averageTotal < 1 && averageTotal != 0)
            {
                let s = String(format:"%.3f", averageTotal)
                self.careerAveragesScrollGrid.addStatTotal(s.substring(from: s.characters.index(after: s.startIndex)))
            }
            else
            {
                self.careerAveragesScrollGrid.addStatTotal(String(format:"%.1f", averageTotal))
            }
        }
    }
    
    func fillPlayerTotals()
    {
        self.careerTotalsScrollGrid.reset()
        self.careerTotalsScrollGrid.addPlayerHeader("Player Name")
        
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                let user = player["user"] as! PFUser
                let name = "\(user["firstName"] as! String) \(user["lastName"] as! String)"
                self.careerTotalsScrollGrid.addPlayerName(name)
            }
            else
            {
                let name = "\(player["firstName"] as! String) \(player["lastName"] as! String)"
                self.careerTotalsScrollGrid.addPlayerName(name)
                
            }
        }
        
        self.careerTotalsScrollGrid.addPlayerFooter("Totals")
        
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat["calculated"] as! Bool))
            {
                let statName = stat.value(forKey: "short_name") as! String
                self.careerTotalsScrollGrid.addStatHeader(statName)
            }
        }
        self.careerTotalsScrollGrid.statMoveToNextRow()
        
        //set the total data
        var totalsArrays = [String:Double]()
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat["calculated"] as! Bool))
            {
                totalsArrays[stat.value(forKey: "name") as! String] = 0.0
            }
        }
        
        for player in SquadCore.selectedSquadRoster
        {
            let totals = SquadCore.getStatTotalGivenPlayer(player, statTotals: self.currentStatTotals)!
            for stat in SquadCore.selectedSquadStats
            {
                if(!(stat["calculated"] as! Bool))
                {
                    let statName = stat.value(forKey: "name") as! String
                    let value = totals.getTotalForStat(statName)
                    if(value.isNaN)
                    {
                        self.careerTotalsScrollGrid.addStatTotal("N/A")
                    }
                    else
                    {
                        self.careerTotalsScrollGrid.addStatTotal("\(Int(value))")
                        totalsArrays[statName] = totalsArrays[statName]! + value
                    }
                }
            }
            self.careerTotalsScrollGrid.statMoveToNextRow()
        }
        
        //set the totals
        for stat in SquadCore.selectedSquadStats
        {
            if(!(stat["calculated"] as! Bool))
            {
                let total = totalsArrays[stat.value(forKey: "name") as! String]!
                if(total.isNaN)
                {
                    self.careerTotalsScrollGrid.addStatTotal("N/A")
                }
                else
                {
                    self.careerTotalsScrollGrid.addStatTotal("\(Int(total))")
                }
            }
        }
    }

    func setBarButtonColors()
    {
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
            self.careerTotalsStack.isHidden = false
            self.careerAveragesStack.isHidden = false
            self.careerLeadersStack.isHidden = true
            self.currToggle = "Stats"
        }
        else if(sender == self.leadersBarButton)
        {
            self.careerTotalsStack.isHidden = true
            self.careerAveragesStack.isHidden = true
            self.careerLeadersStack.isHidden = false
            self.currToggle = "Leaders"
        }
    }

    @IBAction func seasonLeadersPrevStatButtonPressed()
    {
        self.careerLeadersCurrStatPos -= 1
        self.careerLeadersUpdateStat()
    }
    
    @IBAction func seasonLeadersNextStatButtonPressed()
    {
        self.careerLeadersCurrStatPos += 1
        self.careerLeadersUpdateStat()
    }
    
    func careerLeadersUpdateStat()
    {
        self.careerLeadersCurrentStatLabel.text = SquadCore.selectedSquadStats[self.careerLeadersCurrStatPos]["name"] as? String
        self.careerLeadersPrevStatButton.alpha = 1
        self.careerLeadersNextStatButton.alpha = 1
        if(self.careerLeadersCurrStatPos == 0)
        {
            self.careerLeadersPrevStatButton.alpha = 0
        }
        
        if(self.careerLeadersCurrStatPos == SquadCore.selectedSquadStats.count-1)
        {
            self.careerLeadersNextStatButton.alpha = 0
        }
        
        self.careerLeaderCollectionSelectedIndex = self.careerLeadersCurrStatPos
        self.careerLeadersController.setStat(SquadCore.selectedSquadStats[self.careerLeadersCurrStatPos].value(forKey: "name") as! String)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(SquadCore.sznstats_ReloadStats)
        {
            SquadCore.currentStatTotals = SquadCore.getLeaders(SquadCore.currentActiveSeason, roster: SquadCore.selectedSquadRoster)
            SquadCore.sznstats_ReloadStats = false
        }
        
        if(segue.identifier != nil && segue.identifier! == "EmbeddedCareerLeadersTVC")
        {
            self.careerLeadersController = segue.destination as! CareerLeadersTVC
            self.careerLeadersController.currStat = SquadCore.selectedSquadStats[0].value(forKey: "name") as! String
            self.careerLeadersController.careerTotals = self.currentStatTotals
            self.careerLeadersController.refreshData()
        }
        else if(segue.identifier != nil && segue.identifier! == "CareerTotalsEmbed")
        {
            self.careerTotalsScrollGrid = segue.destination as! StatScrollGridVC
        }
        else if(segue.identifier != nil && segue.identifier! == "CareerAveragesEmbed")
        {
            self.careerAveragesScrollGrid = segue.destination as! StatScrollGridVC
        }
    }
}
