//
//  ChatObject.swift
//  Squad
//
//  Created by Michael Litman on 3/8/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class ChatObject: NSObject
{
    var ownerID : String
    var squadID : String
    var message : String
    var timeSince1970 : Double
    
    init(ownerID: String, squadID: String, message: String, timeSince1970: Double)
    {
        self.ownerID = ownerID
        self.squadID = squadID
        self.message = message
        self.timeSince1970 = timeSince1970
    }
    
    func sender() -> String! {
        return ownerID;
    }
}
