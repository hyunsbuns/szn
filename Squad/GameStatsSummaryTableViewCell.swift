//
//  GameStatsSummaryTableViewCell.swift
//  Squad
//
//  Created by Steve on 2/24/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class GameStatsSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scrollContainerPlaceHolder: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
