//
//  SSCell.swift
//  Squad
//
//  Created by Michael Litman on 8/3/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class SSCell: UITableViewCell
{
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
