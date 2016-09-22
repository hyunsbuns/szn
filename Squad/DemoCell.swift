//
//  DemoCell.swift
//  Squad
//
//  Created by Steve on 2/15/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import FoldingCell
import MapKit
import Parse
import GoogleMaps

class DemoCell: FoldingCell
{
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    //@IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ampmLabel: UILabel!
    //@IBOutlet weak var dayofWeekLabel: UILabel!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var mySquadLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    //@IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLabel2: UILabel!

    @IBOutlet weak var mySkwadScore: UILabel!
    @IBOutlet weak var mySkwadLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    //@IBOutlet weak var gameStatsButton: UIButton!
    @IBOutlet weak var winLossLabel: UILabel!
    
    @IBOutlet weak var opponentNameTopLabel: UILabel!
   
    @IBOutlet weak var mySkwadTopLabel: UILabel!
    @IBOutlet weak var mySkwadScoreTop: UILabel!
    @IBOutlet weak var opponentScoreTop: UILabel!
    
    @IBOutlet weak var myTeamImage: UIImageView!
    @IBOutlet weak var opponentImage: UIImageView!
    
    var parentVC : FoldScheduleVC!
    var event : PFObject!
    var lat : CLLocationDegrees!
    var lon : CLLocationDegrees!
    
    func mapClicked()
    {
        let vc = self.parentVC.storyboard?.instantiateViewController(withIdentifier: "MapHolder") as! MapHolderVC
        vc.lat = self.lat
        vc.lon = self.lon
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: vc.view.frame, camera: camera)
        mapView.isMyLocationEnabled = true
        vc.view.addSubview(mapView)
        vc.view.sendSubview(toBack: mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = self.locationLabel2.text!
        marker.snippet = self.locationLabel2.text!
        marker.map = mapView
        self.parentVC.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showActionSheet(_ sender: AnyObject)
    {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let goToGameStats = UIAlertAction(title: "Game Stats", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            //let loadingVC = SquadCore.storyBoard.instantiateViewControllerWithIdentifier("LoadingVC")
            
            //position it relative to the current view
            //let newX = (self.parentVC.view.frame.size.width/2) - 50
            //let newY = (self.parentVC.view.frame.size.height/2) - 50
            //loadingVC.view.frame = CGRectMake(newX, newY, 300, 300)
            
            //place it on the screen using the main queue
            /*
            dispatch_async(dispatch_get_main_queue(), { 
                self.parentVC.view.addSubview(loadingVC.view)
                self.parentVC.view.setNeedsDisplay()
            })
            */
            
            //SquadCore.getStatCollections(SquadCore.selectedSquadRoster, event: self.event, stats: SquadCore.selectedSquadStats)
            SquadCore.selectedEvent = self.event
            let vc = SquadCore.storyBoard.instantiateViewController(withIdentifier: "GameStatsVC") as! GameStatsVC
            self.parentVC.present(vc, animated: true, completion: nil)
            /*
            self.parentVC.presentViewController(vc, animated: true, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    loadingVC.view.removeFromSuperview()
                    self.parentVC.view.setNeedsDisplay()
                })
            })
            */
        })
        let goToRollCall = UIAlertAction(title: "Roll Call", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if(!SquadCore.premiumEnabled)
            {
                let vc = SquadCore.storyBoard.instantiateViewController(withIdentifier: "PremiumRequiredVC") as! PremiumRequiredVC
                vc.navBarTitleText = "Roll Call"
                vc.showBackButton = true
                self.parentVC.present(vc, animated: true, completion: nil)
            }
            else
            {
                let vc = SquadCore.storyBoard.instantiateViewController(withIdentifier: "RollCallVC") as! RollCallVC
                //Let the VC know about the opponent, date, and event
                vc.opponentName = self.opponentNameLabel.text
                vc.date_time = "\(self.monthLabel.text!) \(self.dayLabel.text!) at \(self.timeLabel.text!) \(self.ampmLabel.text!)"
                vc.event = self.event
                vc.imageName = SquadCore.getRollCallStatus(SquadCore.currentUser, event: self.event)
                
                self.parentVC.present(vc, animated: true) { () -> Void in
                    
                }
            }
        })
        let shareToFB = UIAlertAction(title: "Share to Facebook", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //print("File Saved")
        })
        if(SquadCore.isAdmin(SquadCore.selectedSquad, user: SquadCore.currentUser))
        {
            let deleteEvent = UIAlertAction(title: "Delete Event", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this event?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction) in
                    //print("Deleting...")
                    self.event["deleted"] = true
                    self.event.saveInBackground()
                    var pos = SquadCore.selectedSquadFilteredEvents.index(of: self.event)
                    SquadCore.selectedSquadFilteredEvents.remove(at: pos!)
                    pos = SquadCore.selectedSquadEvents.index(of: self.event)
                    SquadCore.selectedSquadEvents.remove(at: pos!)
                    self.parentVC.theTableView.reloadData()
                    SquadCore.sznstats_ReloadStats = true
                })
                
                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.parentVC.present(alert, animated: true, completion: nil)
            })
            optionMenu.addAction(deleteEvent)
        }
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            //print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(goToGameStats)
        optionMenu.addAction(goToRollCall)
        optionMenu.addAction(shareToFB)
        optionMenu.addAction(cancelAction)
        
        //UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(optionMenu, animated: true, completion: nil)
        
        // 5
        self.parentVC.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    /*@IBAction func actionButtonPressed(sender: AnyObject)
    {
        
        let vc = SquadCore.storyBoard.instantiateViewControllerWithIdentifier("RollCallVC") as! RollCallVC
        //Let the VC know about the opponent, date, and event
        vc.opponentName = self.opponentNameLabel.text
        vc.date_time = "\(self.monthLabel.text!) \(self.dayLabel.text!)th \(self.yearLabel.text!) at \(self.timeLabel.text!) \(self.ampmLabel.text!)"
        vc.event = self.event
        vc.imageName = SquadCore.getRollCallStatus(SquadCore.currentUser, event: self.event)
        
        self.parentVC.presentViewController(vc, animated: true) { () -> Void in
            
        }
    }*/
    
    /*@IBAction func gameStatsButtonPressed(sender: AnyObject)
    {
        
        //SquadCore.selectedEvent = SquadCore.selectedSquadFilteredEvents[indexPath.row]
        //get the stat collections for this squad for this event
        SquadCore.getStatCollections(SquadCore.selectedSquadRoster, event: self.event, stats: SquadCore.selectedSquadStats)
        SquadCore.selectedEvent = self.event
        let vc = SquadCore.storyBoard.instantiateViewControllerWithIdentifier("GameStatsVC") as! GameStatsVC
        self.parentVC.presentViewController(vc, animated: true, completion: nil)
        
    }*/

    override func awakeFromNib()
    {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapClicked))
        self.map.addGestureRecognizer(tap)
        // Initialization code
        
        //foregroundView.layer.cornerRadius = 5
        //foregroundView.layer.masksToBounds = true
        //foregroundView.layer.borderWidth = 0.5
        //foregroundView.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        /*
        foregroundView.layer.cornerRadius = 5
        foregroundView.layer.masksToBounds = true
        
        
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        */
        
        winLossLabel.layer.cornerRadius = self.winLossLabel.frame.size.width / 2
        winLossLabel.clipsToBounds = true
        
        myTeamImage.layer.cornerRadius = min(myTeamImage.layer.frame.width, myTeamImage.layer.frame.height)/2
        myTeamImage.layer.masksToBounds = true
        
        opponentImage.layer.cornerRadius = min(opponentImage.layer.frame.width, opponentImage.layer.frame.height)/2
        opponentImage.layer.masksToBounds = true
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }

}
