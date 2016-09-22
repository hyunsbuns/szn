//
//  StatTotals.swift
//  Squad
//
//  Created by Michael Litman on 1/29/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class StatTotals: NSObject
{
    var player : PFObject
    var statCollections = [StatCollection]()
    
    init(player: PFObject)
    {
        self.player = player
    }
    
    func getCollectionForEvent(_ event: PFObject) -> StatCollection?
    {
        for collection in statCollections
        {
            if(collection.event.objectId! == event.objectId!)
            {
                return collection
            }
        }
        return nil
    }
    
    func addStatCollection(_ collection: StatCollection)
    {
        self.statCollections.append(collection)
    }
    
    func getAverageForStat(_ statName: String) -> Double
    {
        var total = 0.0
        for statCollection in self.statCollections
        {
            if(statCollection.shouldCountInTotals!)
            {
                total += Double(statCollection.getStatValue(statName))
            }
        }
        //let value = round((total/Double(self.statCollections.count))*10)/10
        let value = total/Double(self.statCollections.count)
        if(value.isNaN)
        {
            return 0
        }
        return value
    }
    
    func getTotalForStat(_ statName: String) -> Double
    {
        var total = 0.0
        for statCollection in self.statCollections
        {
            if(statCollection.shouldCountInTotals!)
            {
                total += statCollection.getStatValue(statName)
            }
        }
        return total
    }
}
