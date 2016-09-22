//
//  SeasonLeadersTVCell.swift
//  Squad
//
//  Created by Steve on 1/29/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import ParseUI
import Spring

class SeasonLeadersTVCell: UITableViewCell {

    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var playerNameLabel: SpringLabel!
    @IBOutlet weak var statCountLabel: SpringLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
