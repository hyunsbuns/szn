        //
//  StatCollectionCell.swift
//  Squad
//
//  Created by Michael Litman on 12/29/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Spring

class StatCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var statName : UILabel!
    @IBOutlet weak var stepperUp: UIButton!
    @IBOutlet weak var stepperDown: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var downBorder: SpringView!
    @IBOutlet weak var upBorder: SpringView!
    
    var count = 0.0
    var collection : StatCollection!
    var parentPlayerStatVC : PlayerStatVC!
    
        
    @IBAction func stepperDownPressed(_ sender: AnyObject)
    {
        SquadCore.setStatRefresh()
        if count <= 0 {
            count = 0
        } else {
        
        count -= 1
        
        countLabel.text = "\(Int(count))"
        
        }
        self.downBorder.animation = "pop"
        self.downBorder.animate()
        
        self.collection.setStat(self.statName.text!, value: count)
    }
    
    
    @IBAction func stepperUpPressed(_ sender: AnyObject)
    {
        SquadCore.setStatRefresh()
        count += 1
        countLabel.text = "\(Int(count))"
        self.upBorder.animation = "pop"
        self.upBorder.animate()
        
        //update the actual state PFObject
        self.collection.setStat(self.statName.text!, value: count)
        
        if(!self.parentPlayerStatVC.attendedSwitch.isOn)
        {
            self.parentPlayerStatVC.attendedSwitch.isOn = true
            self.parentPlayerStatVC.toggleDidAttendSwitch()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        downBorder.layer.cornerRadius = min(downBorder.layer.frame.width, downBorder.layer.frame.height)/2
        downBorder.layer.masksToBounds = true
        
        upBorder.layer.cornerRadius = self.upBorder.frame.size.width / 2
        upBorder.clipsToBounds = true
    }

}
