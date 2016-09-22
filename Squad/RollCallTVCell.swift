//
//  RollCallTVCell.swift
//  Squad
//
//  Created by Steve on 1/31/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import ParseUI

class RollCallTVCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: PFImageView!
    
    @IBOutlet weak var rcIcon: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }

}
