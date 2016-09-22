//
//  RosterCollectionCell.swift
//  Squad
//
//  Created by Steve on 1/7/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import ParseUI

class RosterCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var cellBG: UIView!
    
    @IBOutlet weak var playerName: UILabel!
    
    @IBOutlet weak var jerseyNumberLabel: UILabel!
    @IBOutlet weak var playerImage: PFImageView!
    
    @IBOutlet weak var featured_stat1_name: UILabel!
    @IBOutlet weak var featured_stat1_value: UILabel!
    
    @IBOutlet weak var featured_stat2_name: UILabel!
    @IBOutlet weak var featured_stat2_value: UILabel!
    
    @IBOutlet weak var featured_stat3_name: UILabel!
    @IBOutlet weak var featured_stat3_value: UILabel!
    
    @IBOutlet weak var featured_stat4_name: UILabel!
    @IBOutlet weak var featured_stat4_value: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        cellBG.layer.cornerRadius = 5
        playerImage.layer.cornerRadius = self.playerImage.frame.size.width / 2
        playerImage.clipsToBounds = true
    }
    
}
