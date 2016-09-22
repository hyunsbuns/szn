//
//  ProfileVC.swift
//  Squad
//
//  Created by Steve on 12/26/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    var player : PFObject!
    var totals : StatTotals!
    var statNamesForTotals = [PFObject]()
    let offset_HeaderStop:CGFloat = 156.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 80.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 65.0 // The distance between the bottom of the Header and the top of the White Label
    
    let offset_HeaderMaxStreach:CGFloat = 100.0
    
    @IBOutlet weak var profileImage: PFImageView!

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var teamImage: PFImageView!
    
    @IBOutlet weak var playerNameLabel: UILabel!
    
    @IBOutlet weak var playerNavBarLabel: UILabel!
    
    @IBOutlet weak var positionNavBarLabel: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var menuToolBar: UIToolbar!
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var header:UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var editButton: UIButton!
    //Toggle Buttons
    @IBOutlet weak var sznAvgButton: UIBarButtonItem!
    @IBOutlet weak var sznTotButton: UIBarButtonItem!
    @IBOutlet weak var careerAvgButton: UIBarButtonItem!
    @IBOutlet weak var careerTotButton: UIBarButtonItem!
    
    //@IBOutlet var segmentControl:UISegmentedControl!
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    var statTotals : StatTotals!
    var currToggle = "SEASON TOTALS"
    
    var appearance = UITabBarItem.appearance()
    
    @IBAction func backBtnPressed(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil )
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.editButton.isHidden = true
        
        //get stat totals for selected user
        self.getStatTotals()
        
        self.sznTotButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 14)!], for: UIControlState())
        
        self.sznAvgButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 14)!], for: UIControlState())
        
        self.careerAvgButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 14)!], for: UIControlState())
        
        self.careerTotButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "TradeGothicLT-BoldCondTwenty", size: 14)!], for: UIControlState())
        
        profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        self.loadData()
    }

    func loadData()
    {
        let user = self.player["user"]
        var name = ""
        var jerseyNumber = ""
        var position1 = ""
        var position2 = ""
        if(user == nil)
        {
            self.editButton.isHidden = false
            let fname = player["firstName"] as! String
            let lname = player["lastName"] as! String
            name = "\(fname) \(lname)".uppercased()
            let imageName = player["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: profileImage, imageName: imageName as! String, profileImage: true)
            }
        }
        else
        {
            let imageName = (user as! PFUser)["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: profileImage, imageName: imageName as! String, profileImage: true)
            }
            
            name = "\((user as! PFUser)["firstName"] as! String) \((user as! PFUser)["lastName"] as! String)".uppercased()
        }
        
        if(player["jersey_number"] != nil)
        {
            jerseyNumber = player["jersey_number"]! as! String
        }
        
        if(player["position1"] != nil)
        {
            let position = player["position1"]! as! PFObject
            try! position.fetchIfNeeded()
            position1 = position["position"]! as! String
        }
        
        if(player["position2"] != nil)
        {
            let position = player["position2"]! as! PFObject
            try! position.fetchIfNeeded()
            position2 = position["position"]! as! String
        }

        playerNameLabel.text = name
        if(jerseyNumber != "")
        {
            jerseyNumber = "#\(jerseyNumber)"
        }
        
        var positions = ""
        if(position1 != "")
        {
            positions = "\(position1)"
        }
        if(position2 != "")
        {
            positions = "\(positions)/\(position2)"
        }
        self.positionLabel.text = "\(jerseyNumber) \(positions)"
        
        playerNavBarLabel.text = name
        playerNavBarLabel.alpha = 0
        
        positionNavBarLabel.alpha = 0
    }
    
    @IBAction func editButtonPressed()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddDummyVC") as! AddDummyVC
        vc.editMode = true
        vc.parentProfileVC = self
        vc.player = self.player
        self.present(vc, animated: true, completion: nil)
    }
    
    func getStatTotals()
    {
        if(self.currToggle == "SEASON TOTALS" || self.currToggle == "SEASON AVERAGES")
        {
            //self.statTotals = SquadCore.getLeaders(SquadCore.currentActiveSeason, roster: [self.player])
            self.statTotals = StatTotals(player: self.player)
            for collection in self.totals.statCollections
            {
                if((collection.event["season"] as! PFObject).objectId! == SquadCore.currentActiveSeason.objectId!)
                {
                    self.statTotals.addStatCollection(collection)
                }
            }
        }
        else
        {
            self.statTotals = self.totals
        }
    }
    
    @IBAction func toggleButtonPressed(_ sender: UIBarButtonItem)
    {
        if(sender == self.sznAvgButton)
        {
            self.currToggle = "SEASON AVERAGES"
        }
        else if(sender == self.sznTotButton)
        {
            self.currToggle = "SEASON TOTALS"
        }
        else if(sender == self.careerAvgButton)
        {
            self.currToggle = "CAREER AVERAGES"
        }
        else if(sender == self.careerTotButton)
        {
            self.currToggle = "CAREER TOTALS"
        }
        self.getStatTotals()
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        //UIApplication.sharedApplication().statusBarStyle = .LightContent
        let height = CGFloat(SquadCore.selectedSquadStats.count)/2*150
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: height)
        
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = profileImage.image
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerImageView?.alpha = 1.0
        header.insertSubview(headerImageView, belowSubview: profileImage)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = profileImage.image?.blurredImage(withRadius: 20, iterations: 20, tintColor: UIColor.black)
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 1.0
        header.insertSubview(headerBlurImageView, belowSubview: profileImage)
        
        header.clipsToBounds = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = profileImage.image
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerImageView?.alpha = 1.0
        header.insertSubview(headerImageView, belowSubview: profileImage)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = profileImage.image?.blurredImage(withRadius: 20, iterations: 20, tintColor: UIColor.black)
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 1.0
        header.insertSubview(headerBlurImageView, belowSubview: profileImage)
        
        header.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -max(offset, -offset_HeaderMaxStreach) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            playerNameLabel.alpha   = -min(1.0, -(offset) / (header.bounds.height/2))
            profileImage.alpha      = playerNameLabel.alpha
            positionLabel.alpha     = playerNameLabel.alpha
            headerImageView.image   = profileImage.image
            headerImageView.alpha   = 1.0
            headerBlurImageView?.alpha = 1 - (headerScaleFactor * 1.5);
            header.layer.transform  = headerTransform
            //segmentControl.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -max(offset, -offset_HeaderMaxStreach), 0)
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
        
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
    
            headerBlurImageView?.alpha = 1.0
            
            profileImage.alpha      = -min(1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            playerNameLabel.alpha   = -min(1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            positionLabel.alpha     = -min(1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            headerImageView?.image  = profileImage.image
            header.layer.transform  = headerTransform
            //segmentControl.layer.transform = headerTransform
            playerNavBarLabel.alpha = +min(1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            positionNavBarLabel.alpha = +min(1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(self.currToggle == "SEASON TOTALS" || self.currToggle == "CAREER TOTALS")
        {
            self.statNamesForTotals.removeAll()
            var count = 0
            for stat in SquadCore.selectedSquadStats
            {
                if(!SquadCore.isStatCalculated(stat["name"] as! String))
                {
                    self.statNamesForTotals.append(stat)
                    count += 1
                }
            }
            self.collectionView.setHeight((CGFloat(count)/2+1)*120)
            return count
        }
        else
        {
            self.collectionView.setHeight((CGFloat(SquadCore.selectedSquadStats.count)/2+1)*120)
            return SquadCore.selectedSquadStats.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileStatsCVCell
        
        if(self.currToggle == "SEASON TOTALS")
        {
            let stat = self.statNamesForTotals[(indexPath as NSIndexPath).row]
            let statName = stat["name"] as! String
            cell.statLabel.text = statName

            let value = self.statTotals.getTotalForStat(statName)
            if(value.isNaN)
            {
                cell.statCountLabel.text = "N/A"
            }
            else
            {
                cell.statCountLabel.text = "\(Int(value))"
            }
            
            self.sznTotButton.tintColor = skwadDarkGrey
            self.sznAvgButton.tintColor = UIColor.lightGray
            self.careerTotButton.tintColor = UIColor.lightGray
            self.careerAvgButton.tintColor = UIColor.lightGray
        }
        else if(self.currToggle == "SEASON AVERAGES")
        {
            let stat = SquadCore.selectedSquadStats[(indexPath as NSIndexPath).row]
            let statName = stat["name"] as! String
            cell.statLabel.text = statName

            let value = self.statTotals.getAverageForStat(statName)
            var s = ""
            if(value < 1 && value != 0.0)
            {
                s = String(format:"%.3f", value)
                s = s.substring(from: s.characters.index(after: s.startIndex))
            }
            else
            {
                s = String(format:"%.1f", value)
            }
            cell.statCountLabel.text = s
            self.sznTotButton.tintColor = UIColor.lightGray
            self.sznAvgButton.tintColor = skwadDarkGrey
            self.careerTotButton.tintColor = UIColor.lightGray
            self.careerAvgButton.tintColor = UIColor.lightGray
        }
        else if(self.currToggle == "CAREER TOTALS")
        {
            let stat = self.statNamesForTotals[(indexPath as NSIndexPath).row]
            let statName = stat["name"] as! String
            cell.statLabel.text = statName
            let value = self.statTotals.getTotalForStat(statName)
            if(value.isNaN)
            {
                cell.statCountLabel.text = "N/A"
            }
            else
            {
                cell.statCountLabel.text = "\(Int(value))"
            }

            self.sznTotButton.tintColor = UIColor.lightGray
            self.sznAvgButton.tintColor = UIColor.lightGray
            self.careerTotButton.tintColor = skwadDarkGrey
            self.careerAvgButton.tintColor = UIColor.lightGray
        }
        else if(self.currToggle == "CAREER AVERAGES")
        {
            let stat = SquadCore.selectedSquadStats[(indexPath as NSIndexPath).row]
            let statName = stat["name"] as! String
            cell.statLabel.text = statName
            let value = self.statTotals.getAverageForStat(statName)
            var s = ""
            if(value < 1 && value != 0.0)
            {
                s = String(format:"%.3f", value)
                s = s.substring(from: s.characters.index(after: s.startIndex))
            }
            else
            {
                s = String(format:"%.1f", value)
            }
            cell.statCountLabel.text = s
            self.sznTotButton.tintColor = UIColor.lightGray
            self.sznAvgButton.tintColor = UIColor.lightGray
            self.careerTotButton.tintColor = UIColor.lightGray
            self.careerAvgButton.tintColor = skwadDarkGrey
        }
        return cell
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
