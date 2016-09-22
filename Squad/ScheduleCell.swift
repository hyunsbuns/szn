//
//  ScheduleCell.swift
//  Squad
//
//  Created by Michael Litman on 12/10/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Spring
import MapKit

class ScheduleCell: UICollectionViewCell
{
    //@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    //@IBOutlet weak var mySquadLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mySkwadScore: UILabel!
    @IBOutlet weak var mySkwadLabel: UILabel!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var winLossLabel: UILabel!
    @IBOutlet weak var rollCallButton: SpringButton!
    

    
    override func awakeFromNib()
    {
        
        //dateTimeLabel.hidden = true
        self.layer.cornerRadius = 5 
        self.clipsToBounds = true
        
        rollCallButton.layer.cornerRadius = min(rollCallButton.layer.frame.width, rollCallButton.layer.frame.height)/2
        rollCallButton.layer.masksToBounds = true
        
        winLossLabel.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        
        winLossLabel.layer.cornerRadius = self.winLossLabel.frame.size.width / 2
        winLossLabel.clipsToBounds = true
        
        
        
        //self.layer.borderWidth = 0.2
        //let LGColor: UIColor = UIColor( red: CGFloat(208/255.0), green: CGFloat(208/255.0), blue: CGFloat(208/255.0), alpha: CGFloat(100.0) )
        //self.layer.borderColor = LGColor.CGColor
        
    }
}
