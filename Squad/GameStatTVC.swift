//
//  GameStatTVC.swift
//  Squad
//
//  Created by Steve on 1/12/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class GameStatTVC: UITableViewCell {

    @IBOutlet weak var playerName: UILabel!
    
    @IBOutlet weak var goalsLabel: UILabel!
    @IBOutlet weak var assistsLabel: UILabel!
    @IBOutlet weak var savesLabel: UILabel!
    @IBOutlet weak var goalsAllowedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
