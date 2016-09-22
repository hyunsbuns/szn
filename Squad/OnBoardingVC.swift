//
//  OnBoardingVC.swift
//  Squad
//
//  Created by Michael Litman on 7/21/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
//import paper_onboarding

class OnBoardingVC: UIViewController
{
    
    @IBOutlet weak var actionButton: UIButton!
    
    //var onboardingScreens = [OnboardingItemInfo]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    /*self.onboardingScreens.append(self.getOnboardItemInfo("skwadGoals", title: "Page 1", description: "Description 1", iconName: "chat icon", color: UIColor.red, titleColor: UIColor.blue, descriptionColor: UIColor.green, titleFont: UIFont.boldSystemFont(ofSize: 18), descriptionFont: UIFont.boldSystemFont(ofSize: 14)))
        
    self.onboardingScreens.append(self.getOnboardItemInfo("skwadGoals", title: "Page 2", description: "Description 2", iconName: "chat icon", color: UIColor.blue, titleColor: UIColor.red, descriptionColor: UIColor.green, titleFont: UIFont.boldSystemFont(ofSize: 18), descriptionFont: UIFont.boldSystemFont(ofSize: 14)))

    self.onboardingScreens.append(self.getOnboardItemInfo("skwadGoals", title: "Page 3", description: "Description 3", iconName: "chat icon", color: UIColor.green, titleColor: UIColor.red, descriptionColor: UIColor.blue, titleFont: UIFont.boldSystemFont(ofSize: 18), descriptionFont: UIFont.boldSystemFont(ofSize: 14)))

        let onboarding = PaperOnboarding()
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom]
        {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
        self.view.bringSubview(toFront: self.actionButton)
        */
        // Do any additional setup after loading the view.
    }

    /*
    func getOnboardItemInfo(_ imageName: String, title: String, description: String, iconName: String, color: UIColor, titleColor: UIColor, descriptionColor: UIColor, titleFont: UIFont, descriptionFont: UIFont) -> OnboardingItemInfo
    {
        return (imageName, title, description, iconName, color, titleColor, descriptionColor, titleFont, descriptionFont)
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo
    {
        return self.onboardingScreens[index]
    }
    
    func onboardingItemsCount() -> Int
    {
        return self.onboardingScreens.count
    }
    
    func onboardingWillTransitonToIndex(_ index: Int)
    {
    }
    
    func onboardingDidTransitonToIndex(_ index: Int)
    {
    }
    
 */
    /**
     Tells the delegate the PaperOnboarding is about to draw a item for a particular row. Use this method for configure items
     
     - parameter item:  A OnboardingContentViewItem object that PaperOnboarding is going to use when drawing the row.
     - parameter index: An curretn index item
     */
    /*
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int)
    {
        if(index == self.onboardingScreens.count-1)
        {
            self.actionButton.setTitle("done", for: UIControlState())
            self.actionButton.setTitle("done", for: .highlighted)
            self.actionButton.setTitle("done", for: .focused)
            
        }
        else
        {
            self.actionButton.setTitle("skip", for: UIControlState())
            self.actionButton.setTitle("skip", for: .highlighted)
            self.actionButton.setTitle("skip", for: .focused)
            
        }
    }
    */
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
