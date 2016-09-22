//
//  WebGridVC.swift
//  Squad
//
//  Created by Michael Litman on 3/29/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class StatScrollGridVC: UIViewController
{
    @IBOutlet weak var statScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statScrollView: UIScrollView!
    @IBOutlet weak var playerScrollView: UIScrollView!
    
    var currPlayerX = CGFloat(0.0)
    var currPlayerY = CGFloat(0.0)
    var currStatX = CGFloat(0.0)
    var currStatY = CGFloat(0.0)
    var origStatFrame : CGRect!
    var origStatContentSize : CGSize!
    var origPlayerFrame : CGRect!
    var origPlayerContentSize : CGSize!
    let gap = CGFloat(20)
    let statGap = CGFloat(5)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.origStatFrame = self.statScrollView.frame
        self.origStatContentSize = self.statScrollView.contentSize
        self.origPlayerFrame = self.playerScrollView.frame
        self.origPlayerContentSize = self.playerScrollView.contentSize
        
        /*
        //set our position for the first actual row of stats
        //self.currStatY = self.gap
        self.addPlayerHeader("PLAYER NAME")
        for(var i = 0; i < 25; i += 1)
        {
            self.addPlayerName("Player \(i)")
        }
        self.addPlayerFooter("Totals:")
        
        self.addStatHeader("IP")
        self.addStatHeader("ERA")
        self.addStatHeader("SB")
        self.addStatHeader("H")
        self.addStatHeader("SLUG")
        self.addStatHeader("IP")
        self.addStatHeader("ERA")
        self.addStatHeader("SB")
        self.addStatHeader("H")
        self.addStatHeader("SLUG")
        self.addStatHeader("IP")
        self.addStatHeader("ERA")
        self.addStatHeader("SB")
        self.addStatHeader("H")
        self.addStatHeader("SLUG")
        
        for(var i = 0; i < 25; i += 1)
        {
            self.statMoveToNextRow()
            for(var j = 0; j < 15; j += 1)
            {
                self.addStatValue("\(j)")
            }
        }
        
        self.statMoveToNextRow()
        for(var j = 0; j < 15; j += 1)
        {
            self.addStatTotal("\(j*3)")
        }
        */
        // Do any additional setup after loading the view.
    }

    func reset()
    {
        currPlayerX = CGFloat(0.0)
        currPlayerY = CGFloat(0.0)
        currStatX = CGFloat(0.0)
        currStatY = CGFloat(0.0)
        for view in self.statScrollView.subviews
        {
            view.removeFromSuperview()
        }
        self.statScrollView.frame = self.origStatFrame
        self.statScrollView.contentSize = self.origStatContentSize
        self.playerScrollView.frame = self.origPlayerFrame
        self.playerScrollView.contentSize = self.origPlayerContentSize
    }
    
    func getHeight() -> CGFloat
    {
        return self.playerScrollView.contentSize.height + 40
    }
    
    func statMoveToNextRow()
    {
        self.currStatX = CGFloat(0.0)
        self.currStatY += self.gap
        self.increaseStatScrollViewFrameHeight(self.gap)
    }
    
    func increaseViewFrameHeight(_ height : CGFloat)
    {
        let newFrame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height + height)
        self.view.frame = newFrame
    }
    
    func increasePlayerScrollViewFrameHeight(_ height : CGFloat)
    {
        let newFrame = CGRect(x: self.playerScrollView.frame.origin.x, y: self.playerScrollView.frame.origin.y, width: self.playerScrollView.frame.size.width, height: self.playerScrollView.frame.size.height + height)
        self.playerScrollView.frame = newFrame
        self.playerScrollView.contentSize = CGSize(width: self.playerScrollView.contentSize.width, height: self.playerScrollView.contentSize.height + height)
        self.playerScrollViewHeightConstraint.constant = self.playerScrollViewHeightConstraint.constant + height
    }

    func increasePlayerScrollViewContentViewWidthIfNeeded(_ width : CGFloat)
    {
        if(width > self.playerScrollView.contentSize.width)
        {
            self.playerScrollView.contentSize = CGSize(width: width, height: self.playerScrollView.contentSize.height)
        }
    }
    
    func increaseStatScrollViewContentViewWidthIfNeeded(_ width : CGFloat)
    {
        if((self.currStatX + width) > self.statScrollView.contentSize.width)
        {
            self.statScrollView.contentSize = CGSize(width: self.currStatX + width, height: self.statScrollView.contentSize.height)
        }
    }
    
    func increaseStatScrollViewFrameHeight(_ height : CGFloat)
    {
        let newFrame = CGRect(x: self.statScrollView.frame.origin.x, y: self.statScrollView.frame.origin.y, width: self.statScrollView.frame.size.width, height: self.statScrollView.frame.size.height + height)
        self.statScrollView.frame = newFrame
        self.statScrollView.contentSize = CGSize(width: self.statScrollView.contentSize.width, height: self.statScrollView.contentSize.height + height)
        self.statScrollViewHeightConstraint.constant = self.statScrollViewHeightConstraint.constant + height
    }

    func addStatHeader(_ val : String)
    {
        let labelFrame = CGRect(x: self.currStatX, y: self.currStatY, width: 30, height: 21)
        
        let label = UILabel(frame: labelFrame)
        label.text = val
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.lightGray
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        //label.sizeToFit()
        self.statScrollView.addSubview(label)
        
        //update currStatX
        self.currStatX = self.currStatX + label.frame.size.width + self.statGap
        
        //update scrollview size
        self.increaseStatScrollViewContentViewWidthIfNeeded(label.frame.size.width + (3 * self.statGap))
    }
    
    func addStatValue(_ val : String)
    {
        let labelFrame = CGRect(x: self.currStatX, y: self.currStatY, width: 30, height: 21)
        
        let label = UILabel(frame: labelFrame)
        label.text = val
        label.textAlignment = NSTextAlignment.center
        //label.font = UIFont.systemFontOfSize(14)
        label.textColor = asphaltColor
        label.font = UIFont(name: "AvenirNext-Regular", size: 12)
        self.statScrollView.addSubview(label)
        
        //update currStatX
        self.currStatX = self.currStatX + label.frame.size.width + self.statGap
    }
    
    func addStatTotal(_ val : String)
    {
        let labelFrame = CGRect(x: self.currStatX, y: self.currStatY, width: 30, height: 21)
        
        let label = UILabel(frame: labelFrame)
        label.text = val
        label.textAlignment = NSTextAlignment.center
        //label.font = UIFont.systemFontOfSize(14)
        label.textColor = asphaltColor
        label.font = UIFont(name: "AvenirNext-Medium", size: 12)
        self.statScrollView.addSubview(label)
        
        //update currStatX
        self.currStatX = self.currStatX + label.frame.size.width + self.statGap
    }
    
    func addPlayerHeader(_ val : String)
    {
        let labelFrame = CGRect(x: self.currPlayerX, y: self.currPlayerY, width: self.playerScrollView.frame.size.width, height: 21)
        
        //move to next row with gap pixel gap
        self.currPlayerY += gap
        
        let label = UILabel(frame: labelFrame)
        label.text = val
        label.textColor = UIColor.lightGray
        label.font = UIFont(name: "AvenirNext-Medium", size: 12)
        self.playerScrollView.addSubview(label)
        
        //update scrollview size
        self.increaseViewFrameHeight(gap)
        self.increasePlayerScrollViewFrameHeight(gap)
        self.increasePlayerScrollViewContentViewWidthIfNeeded(label.frame.size.width)
    }
    
    func addPlayerName(_ name : String)
    {
        let labelFrame = CGRect(x: self.currPlayerX, y: self.currPlayerY, width: self.playerScrollView.frame.size.width, height: 21)
        
        //move to next row with gap pixel gap
        self.currPlayerY += gap
        
        let label = UILabel(frame: labelFrame)
        label.text = name
        label.textColor = asphaltColor
        label.font = UIFont(name: "AvenirNext-Regular", size: 12)
        label.sizeToFit()
        label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.size.width, height: 21)
        self.playerScrollView.addSubview(label)
        
        //update scrollview size
        self.increaseViewFrameHeight(gap)
        self.increasePlayerScrollViewFrameHeight(gap)
        self.increasePlayerScrollViewContentViewWidthIfNeeded(label.frame.size.width)
    }
    
    func addPlayerFooter(_ val : String)
    {
        let labelFrame = CGRect(x: self.currPlayerX, y: self.currPlayerY, width: self.playerScrollView.frame.size.width, height: 21)
        
        //move to next row with gap pixel gap
        self.currPlayerY += gap
        
        let label = UILabel(frame: labelFrame)
        label.text = val
        label.textColor = UIColor.lightGray
        label.font = UIFont(name: "AvenirNext-Medium", size: 12)
        self.playerScrollView.addSubview(label)
        
        //update scrollview size
        self.increaseViewFrameHeight(gap)
        self.increasePlayerScrollViewFrameHeight(gap)
        self.increasePlayerScrollViewContentViewWidthIfNeeded(label.frame.size.width)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
