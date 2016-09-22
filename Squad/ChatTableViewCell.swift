//
//  ChatTableViewCell.swift
//  Squad
//
//  Created by Michael Litman on 12/21/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import ParseUI

class ChatTableViewCell: UITableViewCell
{
    @IBOutlet weak var ownerLabel : UILabel!
    @IBOutlet weak var messageTextView : UITextView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var ownerImage: PFImageView!
    @IBOutlet weak var messageContainer: UIView!
    var message:String!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        messageTextView.text = message
        
        ownerImage.layer.cornerRadius = self.ownerImage.frame.size.width / 2
        ownerImage.clipsToBounds = true
        
        messageContainer.layer.cornerRadius = 8
        messageContainer.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
