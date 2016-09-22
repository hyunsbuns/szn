//
//  ManageRosterVC.swift
//  Squad
//
//  Created by Michael Litman on 7/19/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class ManageRosterVC: UIViewController
{
    var rosterList : ManageRosterList!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveButtonPressed()
    {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you wish to permanently remove the selected players from the roster?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction) in
            let players = self.rosterList.data
            let checkmarks = self.rosterList.checkMarks
            for i in 0 ..< players.count
            {
                if(checkmarks[i])
                {
                    let player = players[i]
                    player["isActive"] = false
                    player.saveInBackground()
                }
            }
            let completeAlert = UIAlertController(title: "Success", message: "The updated roster will take effect the next time you login.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            })
            completeAlert.addAction(okAction)
            self.present(completeAlert, animated: true, completion: nil)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        self.rosterList = segue.destination as! ManageRosterList
    }
    

}
