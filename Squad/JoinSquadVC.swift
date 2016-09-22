//
//  JoinSquadVC.swift
//  Squad
//
//  Created by Michael Litman on 11/27/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse

class JoinSquadVC: UIViewController
{
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var squadCodeTF: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.errorLabel.isHidden = true
        
        self.view.backgroundColor = asphaltColor
        // Do any additional setup after loading the view.
    }

    @IBAction func joinButtonPressed(_ sender: AnyObject)
    {
        if(self.squadCodeTF.text == "")
        {
            errorLabel.text = "You must enter a Squad Code!"
            self.errorLabel.isHidden = false
        }
        else
        {
            let query = PFQuery(className: "Invites")
            query.whereKey("objectId", equalTo: self.squadCodeTF.text!)
            let objects = try! query.findObjects()
            if(objects.count == 1)
            {
                errorLabel.isHidden = true
                let objectToDelete = objects[0]
                let squad = objectToDelete["squadID"] as! PFObject
                let player = PFObject(className: "Player")
                player["user"] = SquadCore.currentUser
                player["squad"] = squad
                player["dummy"] = false
                player["isAdmin"] = false
                player["isActive"] = true
                player.saveInBackground(block: { (success: Bool, error: Error?) in
                    if(success)
                    {
                        objectToDelete.deleteInBackground()
                        try! squad.fetchIfNeeded()
                        SquadCore.theSquads.append(squad)
                        SquadCore.theSquadsCollectionView.reloadData()
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
            else
            {
                errorLabel.text = "Problem Joining Squad, Try Again!"
                errorLabel.isHidden = false
            }
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
