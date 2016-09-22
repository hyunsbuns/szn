//
//  StartNewSeasonVC.swift
//  Squad
//
//  Created by Michael Litman on 7/28/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class StartNewSeasonVC: UIViewController
{
    @IBOutlet weak var seasonNameTF: UITextField!
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.seasonNameTF.becomeFirstResponder()
        
        self.navBar.tintColor = UIColor.white
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            cancelBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func startSeasonButtonPressed()
    {
        var message = ""
        if(self.seasonNameTF.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "")
        {
            message = "You must enter a season name"
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let query = PFQuery(className: "Season")
            query.whereKey("squad", equalTo: SquadCore.selectedSquad)
            query.findObjectsInBackground(block: { (objects:[PFObject]?, error: Error?) in
                for object in objects!
                {
                    let name = object["name"] as! String
                    if(name == self.seasonNameTF.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    {
                        message = "You already have a squad named that."
                    }
                }
                if(message != "")
                {
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    //add the new season and make it active
                    let obj = PFObject(className: "Season")
                    obj["isActive"] = true
                    obj["squad"] = SquadCore.selectedSquad
                    obj["name"] = self.seasonNameTF.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    obj.saveInBackground(block: { (success: Bool, error: Error?) in
                        if(success)
                        {
                            for oldSeason in objects!
                            {
                                let isActive = oldSeason["isActive"] as! Bool
                                if(isActive)
                                {
                                    oldSeason["isActive"] = false
                                    oldSeason.saveInBackground()
                                }
                            }

                            let alert = UIAlertController(title: "Success", message: "The new season has been started.  The next time you login, the new season will be the active season.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Error", message: "Something went wrong, please try again.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
            })
        }
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
