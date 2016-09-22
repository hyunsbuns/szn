//
//  SquadTableViewCell.swift
//  Squad
//
//  Created by Michael Litman on 11/27/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit

class SquadTableViewCell: UITableViewCell
{
    @IBOutlet weak var teamImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var numMembersLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        teamImage.layer.cornerRadius = 5
        teamImage.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}


