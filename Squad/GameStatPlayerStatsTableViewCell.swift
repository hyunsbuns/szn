//
//  GameStatPlayerStatsTableViewCell.swift
//  Squad
//
//  Created by Michael Litman on 2/23/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class GameStatPlayerStatsTableViewCell: UITableViewCell
{
    @IBOutlet weak var statNameLabel: UILabel!
    @IBOutlet weak var statValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
