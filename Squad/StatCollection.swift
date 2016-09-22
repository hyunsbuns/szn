//
//  StatCollection.swift
//  Squad
//
//  Created by Michael Litman on 1/11/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class StatCollection: NSObject
{
    var player : PFObject!
    var event : PFObject!
    var statRecords : [PFObject]!
    var shouldCountInTotals : Bool!
    var startPos = 0
    var op = Character("?")
    var currShortStatName = ""
    var leftValue = -1.0
    var outputStack = [String]()
    var opStack = [Character]()
    
    init(player: PFObject, event: PFObject, stats: [PFObject])
    {
        super.init()
        self.player = player
        self.event = event
        let query = PFQuery(className: "StatRecord")
        query.whereKey("player", equalTo: self.player)
        query.whereKey("event", equalTo: self.event)
        query.includeKey("stat")
        try! self.statRecords = query.findObjects()
        //print(self.statRecords.debugDescription)
        //check to make sure all the stats are there and create new ones for the missing
        self.addMissingStats(stats)
        //print(self.statRecords.debugDescription)

        self.shouldCountInTotals = self.statRecords.first?.value(forKey: "did_attend") as! Bool
    }
   
    init(player: PFObject, event: PFObject, stats: [PFObject], statRecords: [PFObject])
    {
        self.player = player
        self.event = event
        self.statRecords = [PFObject]()
        super.init()
        
        for record in statRecords
        {
            let recordPlayer = record.value(forKey: "player") as! PFObject
            let recordEvent = record.value(forKey: "event") as! PFObject
            if(self.player.objectId! == recordPlayer.objectId! && self.event.objectId! == recordEvent.objectId!)
            {
                self.statRecords.append(record)
            }
        }
        
        //check to make sure all the stats are there and create new ones for the missing
        self.addMissingStats(stats)
        self.shouldCountInTotals = self.statRecords.first?.value(forKey: "did_attend") as! Bool
    }
    
    func display()
    {
        /*
        for sr in self.statRecords
        {
            print(sr.debugDescription)
        }
        */
    }
    
    func addMissingStats(_ stats: [PFObject])
    {
        //check to make sure all the stats are there and create new ones for the missing
        for s in stats
        {
            if(!hasStat(s))
            {
                let record = PFObject(className: "StatRecord")
                record.setValue(player, forKey: "player")
                record.setValue(event, forKey: "event")
                record.setValue(s, forKey: "stat")
                record.setValue(0, forKey: "value")
                self.statRecords.append(record)
            }
        }
        
        //check to see if they have a hasAttended
        let aRecord = self.statRecords.first
        
        if(aRecord?.value(forKey: "did_attend") == nil)
        {
            for record in self.statRecords
            {
                record.setValue(false, forKey: "did_attend")
            }
        }
        

    }
    
    //save all of the stat records that have been changed to parse
    func save()
    {
        //save assuming the dirty bit is set
        for record in self.statRecords
        {
            record.saveInBackground()
        }
    }
    
    fileprivate func hasStat(_ stat: PFObject) -> Bool
    {
        for record in self.statRecords
        {
            if((record.value(forKey: "stat") as! PFObject).objectId == stat.objectId)
            {
                return true
            }
        }
        return false
    }
    
    func getShortStatValue(_ shortStatName: String) -> Double
    {
        for record in self.statRecords
        {
            let currentStat = record.value(forKey: "stat") as! PFObject
            //try! currentStat.fetchIfNeeded()
            if((currentStat.value(forKey: "short_name") as! String) == shortStatName)
            {
                return self.getStatValue(currentStat.value(forKey: "name") as! String)
            }
        }
        return -1
    }
    
    func getStatValue(_ statName: String) -> Double
    {
        //print(self.statRecords.debugDescription)
        for record in self.statRecords
        {
            let currentStat = record["stat"] as! PFObject
            //try! currentStat.fetchIfNeeded()
            //print(currentStat.debugDescription)
            let currName = currentStat["name"] as! String
            if(currName == statName)
            {
                if(currentStat["calculated"] as! Bool)
                {
                    return self.calcStat(currentStat)
                }
                else
                {
                    return record["value"] as! Double
                }
            }
        }
        return -1
    }
    
    func isOp(_ token: Character) -> Bool
    {
        return token == "+" || token == "-" || token == "/" || token == "*"
    }
    
    func doMath(_ op: Character, leftNum: Double, rightNum: Double) -> Double
    {
        if(op == "+")
        {
            return leftNum + rightNum
        }
        else if(op == "-")
        {
            return leftNum - rightNum
        }
        else if(op == "/")
        {
            return leftNum / rightNum
        }
        else if(op == "*")
        {
            return leftNum * rightNum
        }
        return -1
    }
    
    func getPrecedent(_ op: Character) -> Int
    {
        if(op == "/" || op == "*")
        {
            return 3
        }
        else if(op == "+" || op == "-")
        {
            return 2
        }
        else if(op == "(")
        {
            return -1
        }
        else
        {
            //for ^ in case we need it
            return 4
        }
    }
    
    func addOutputIfNeeded()
    {
        //if we have a shortStatName built up, push it onto the outputStack and reset
        if(self.currShortStatName.length > 0)
        {
            self.outputStack.append(self.currShortStatName)
            self.currShortStatName = ""
        }
    }
    
    func shuntingYard(_ tokens : [Character])
    {
        while(self.startPos < tokens.count)
        {
            let currChar = tokens[startPos]
            if(currChar == "(")
            {
                self.addOutputIfNeeded()
                self.startPos += 1
                self.opStack.insert(currChar, at: 0)
                self.shuntingYard(tokens)
            }
            else if(currChar == ")")
            {
                self.addOutputIfNeeded()
                while(self.opStack.count > 0 && self.opStack[0] != "(")
                {
                    self.outputStack.append("\(self.opStack.removeFirst())")
                }
                //burn past the (
                self.opStack.removeFirst()
                self.startPos += 1
            }
            else if(self.isOp(currChar))
            {
                self.addOutputIfNeeded()
                while(self.opStack.count > 0 && self.getPrecedent(self.opStack[0]) >= self.getPrecedent(currChar))
                {
                    //pop from opStack onto outputStack
                    self.outputStack.append("\(self.opStack.removeFirst())")
                }
                //push the new op onto the opStack
                self.opStack.insert(currChar, at: 0)
                self.startPos += 1
            }
            else
            {
                //capturing a stat name
                currShortStatName = "\(currShortStatName)\(currChar)"
                self.startPos += 1
            }
        }
        //add any remaining output
        self.addOutputIfNeeded()
        
        //clear the opStack and append to outputStack
        while(self.opStack.count > 0)
        {
            self.outputStack.append("\(self.opStack.removeFirst())")
        }
    }
    
    func resetForShunting()
    {
        self.startPos = 0
        self.op = "?"
        self.opStack.removeAll()
        self.outputStack.removeAll()
    }
    
    func processOutputStack() -> Double
    {
        var localStack = [String]()
        //print("OS Start: \(self.outputStack)")
        while(self.outputStack.count > 0)
        {
            let current = self.outputStack.removeFirst()
            if(self.isOp(current.characters.first!))
            {
                var right = Double(localStack.last!)
                if(right == nil)
                {
                    right = self.getShortStatValue(localStack.last!)
                }
                localStack.removeLast()
                
                var left = Double(localStack.last!)
                if(left == nil)
                {
                    left = self.getShortStatValue(localStack.last!)
                }
                localStack.removeLast()
                localStack.append("\(self.doMath(current.characters.first!, leftNum: left!, rightNum: right!))")
            }
            else
            {
                localStack.append(current)
            }
        }
        return Double(localStack.removeFirst())!
    }
    
    func calcStat(_ stat: PFObject) -> Double
    {
        let formula = stat.value(forKey: "formula") as! String
        //let formula	= "(1B+(2B*2)+(3B*3)+(HR*4))/AB"
        var tokens = [Character]()
        for c in formula.characters
        {
            if(c == " ")
            {
                continue
            }
            tokens.append(c)
        }
        //print(tokens)
        
        //reset before an initial call to shuntingYard
        self.resetForShunting()
        
        self.shuntingYard(tokens)
        //print(formula)
        //print(self.outputStack)
        let answer = self.processOutputStack()
        //print(answer)
        //process the outputStack
        return answer
    }
    
    func setDidAttend(_ value: Bool)
    {
        for record in self.statRecords
        {
            record.setValue(value, forKey: "did_attend")
        }
        self.shouldCountInTotals = value
    }
    
    func didAttend() -> Bool
    {
        //print(self.statRecords.first.debugDescription)
        return self.statRecords.first?.value(forKey: "did_attend") as! Bool
    }
    
    func setStat(_ statName: String, value: Double)
    {
        for record in self.statRecords
        {
            let currentStat = record.value(forKey: "stat") as! PFObject
            if((currentStat.value(forKey: "name") as! String) == statName)
            {
                record.setValue(value, forKey: "value")
                return
            }
        }
    }
}
