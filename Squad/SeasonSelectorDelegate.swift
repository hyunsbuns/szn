//
//  SeasonSelectorDelegate.swift
//  Squad
//
//  Created by Michael Litman on 1/21/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

protocol SeasonSelectorDelegate
{
    var currentSeason : PFObject! { get set }
    var READ_ONLY : Bool { get set }
    func setSeasonLabel()
    func updateActiveInterfaceElements()
}
