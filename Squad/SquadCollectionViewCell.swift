//
//  SquadCollectionViewCell.swift
//  Squad
//
//  Created by Steve on 12/11/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import ParseUI

class SquadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var teamImage: PFImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sportLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //self.layer.borderWidth = 1
        
        //self.layer.borderColor = UIColor.lightGrayColor().CGColor
        // Initialization code
        //self.teamImage.layer.borderWidth = 0.5
        //self.teamImage.layer.borderColor = UIColor.lightGrayColor().CGColor
        //self.teamImage.layer.cornerRadius = 5
        self.teamImage.clipsToBounds = true
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        self.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}


