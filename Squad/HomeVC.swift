//
//  HomeVC.swift
//  Squad
//
//  Created by Michael Litman on 12/10/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKShareKit

class HomeVC: UIViewController, UIScrollViewDelegate, FBSDKSharingDelegate
{
    /*!
     @abstract Sent to the delegate when the sharer encounters an error.
     @param sharer The FBSDKSharing that completed.
     @param error The error.
     */
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
    }

    
    //@IBOutlet weak var imageView: UIImageView!
    let offset_HeaderStop:CGFloat = 86.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 90.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 50.0 // The distance between the bottom of the Header and the top of the White Label
    let offset_HeaderMaxStreach:CGFloat = 100.0
    var announcementsCVC : AnnouncementsCVC!
    
    @IBOutlet weak var teamImage: PFImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var teamRecordLabel: UILabel!
    
    @IBOutlet weak var currentSeasonButton: UIButton!
     
    @IBOutlet weak var navBar: UINavigationBar!
    
    // Changes by BlackScreenTech
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var header:UIView!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var headerRecordLabel:UILabel!
    
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //determine if premium is enabled
        SquadCore.setPremium(SquadCore.selectedSquad["premium_expiration"] as! Date)
        SquadCore.homeVC = self
        
        scrollView.delegate = self
        let owner = SquadCore.selectedSquad["owner_id"] as! PFUser
        if(SquadCore.currentUser.objectId! == owner.objectId!)
        {
            self.postButton.isHidden = false
        }
        else
        {
            self.postButton.isHidden = true
        }
        /*
        self.imageView.hidden = true
        
        let path = NSBundle.mainBundle().pathForResource("background", ofType: "jpeg")
        let image = UIImage(named: path!)
        let p = CGPointMake(0, 0)
        var newImage = SquadCore.drawText("Score", image: image!, point: p)
        newImage = SquadCore.drawText("41 - 28", image: newImage, point: CGPointMake(0, 25))
        
        self.imageView.image = newImage
 */
        //self.navBar.topItem?.title = SquadCore.selectedSquad.valueForKey("name") as? String
        
        /*let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [skwadDarkGrey.CGColor, UIColor.blackColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        */
        self.view.backgroundColor = UIColor.white
        /*
        self.navBar.topItem?.title = ""
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.shadowImage = UIImage()
        self.navBar.translucent = true
        */
        
//        self.teamImage.image = SquadCore.currTeamImage.image
//        self.teamImage.clipsToBounds = true
//        
        self.teamNameLabel.text = "\(SquadCore.selectedSquad.value(forKey: "name") as! String)"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Header - Image
        
        headerLabel.font = UIFont(name: "Shumi", size: 20)
        
        self.view.isUserInteractionEnabled = true;
        
        headerLabel.text = "\(SquadCore.selectedSquad.value(forKey: "name") as! String)".uppercased()
        
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = SquadCore.currTeamImage.image
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = SquadCore.currTeamImage.image?.blurredImage(withRadius: 20, iterations: 20, tintColor: UIColor.black)
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //SquadCore.homeReset()
        
        //calculate record
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
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!)
    {
        //print("image share completed")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!)
    {
        //print("image share cancel")
    }
    
    @IBAction func fbShareButtonPressed(_ sender: AnyObject)
    {
        let image = FBSDKSharePhoto()
        //image.image = self.imageView.image!
        image.caption = "Test Image"
        image.isUserGenerated = true
        let content = FBSDKSharePhotoContent()
        content.photos = [image]
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);

        //UIApplication.sharedApplication().statusBarStyle = .LightContent
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 9999);
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
//            headerBlurImageView?.alpha = min(1.0, -(offset) / (header.bounds.height/2));
            header.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            headerRecordLabel.layer.transform = labelTransform;
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
              header.layer.transform = headerTransform
        }
        
        // Apply Transformations
        
      
    }

    
    
    /* 
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    } */

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
     
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

}
