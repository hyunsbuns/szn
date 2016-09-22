//
//  SeasonTableViewCell.swift
//  Squad
//
//  Created by Michael Litman on 1/28/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class SeasonTotalsTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scrollContainerPlaceHolder: UIView!
    //var scrollContainer : ScrollContainerVC!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //self.backgroundColor = UIColor.blackColor()
        
        
        // Configure the view for the selected state
    }

}
