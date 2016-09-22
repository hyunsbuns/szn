//
//  RosterTableViewCell.swift
//  Squad
//
//  Created by Michael Litman on 12/8/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import ParseUI

class RosterTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImage: PFImageView!
    
    @IBOutlet weak var jerseyNumberLabel: UILabel!
    
    //@IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
